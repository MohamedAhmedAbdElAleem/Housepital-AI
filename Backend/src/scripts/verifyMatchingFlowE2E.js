/* eslint-disable no-console */
require('dotenv').config();

const mongoose = require('mongoose');
const jwt = require('jsonwebtoken');
const axios = require('axios');

const User = require('../models/User');
const Nurse = require('../models/Nurse');
const Service = require('../models/Service');
const NurseOffer = require('../models/NurseOffer');
const MatchingRequest = require('../models/MatchingRequest');

function tokenFor(user) {
  return jwt.sign(
    {
      id: String(user._id),
      email: user.email,
      role: user.role,
    },
    process.env.JWT_SECRET_KEY || 'housepital_secret_key_2024',
    { expiresIn: '2h' },
  );
}

async function ensureTestCustomer() {
  const email = 'matching.test.customer@gmail.com';
  let user = await User.findOne({ email }).select('+password_hash');

  if (!user) {
    const mobile = `010${String(Math.floor(Math.random() * 100000000)).padStart(8, '0')}`;
    user = new User({
      name: 'Matching Test Customer',
      email,
      mobile,
      password_hash: '111111',
      role: 'customer',
      isVerified: true,
      status: 'approved',
      verificationStatus: 'verified',
    });
    await user.save();
  }

  user.role = 'customer';
  user.status = 'approved';
  user.verificationStatus = 'verified';
  user.isVerified = true;
  await user.save();

  return user;
}

async function ensureReadyNurse() {
  const nurse = await Nurse.findOne({}).sort({ updatedAt: -1 });
  if (!nurse) {
    throw new Error('No nurse profile found in DB');
  }

  const nurseUser = await User.findById(nurse.user).select('+password_hash');
  if (!nurseUser) {
    throw new Error('Nurse user account not found');
  }

  nurseUser.role = 'nurse';
  nurseUser.status = 'approved';
  nurseUser.verificationStatus = 'verified';
  nurseUser.isVerified = true;
  if (!nurseUser.password_hash) {
    nurseUser.password_hash = '111111';
  }
  await nurseUser.save();

  nurse.isOnline = true;
  nurse.verificationStatus = 'approved';
  nurse.profileStatus = 'approved';
  nurse.currentLocation = {
    type: 'Point',
    coordinates: [31.2357, 30.0444],
  };

  if (!Array.isArray(nurse.skills)) nurse.skills = [];
  await nurse.save();

  return { nurse, nurseUser };
}

async function pickServiceForNurse(nurse) {
  const activeServices = await Service.find({ type: 'home_nursing', isActive: true })
    .select('_id name category')
    .lean();

  if (!activeServices.length) {
    throw new Error('No active home_nursing services found');
  }

  let service = activeServices.find((s) => Array.isArray(nurse.skills) && nurse.skills.includes(s.category));

  if (!service) {
    service = activeServices[0];
    nurse.skills = Array.isArray(nurse.skills) ? nurse.skills : [];
    if (!nurse.skills.includes(service.category)) {
      nurse.skills.push(service.category);
      await nurse.save();
    }
  }

  return service;
}

async function findOfferForRequest(requestId, nurseId) {
  const started = Date.now();
  while (Date.now() - started < 12000) {
    const offer = await NurseOffer.findOne({
      matchingRequestId: requestId,
      nurseId,
      nurseStatus: 'pending',
      nurseExpiresAt: { $gt: new Date() },
    }).sort({ createdAt: -1 });

    if (offer) return offer;

    await new Promise((resolve) => setTimeout(resolve, 1000));
  }

  return null;
}

async function run() {
  if (!process.env.DATABASE_URI) {
    throw new Error('DATABASE_URI is missing');
  }

  await mongoose.connect(process.env.DATABASE_URI, {
    serverSelectionTimeoutMS: 10000,
  });

  const baseUrl = `http://127.0.0.1:${process.env.PORT || 3500}`;
  const customer = await ensureTestCustomer();
  const { nurse, nurseUser } = await ensureReadyNurse();
  const service = await pickServiceForNurse(nurse);

  const customerToken = tokenFor(customer);
  const nurseToken = tokenFor(nurseUser);

  const stepResults = {
    step1_createRequest: null,
    step2_nurseOfferVisible: null,
    step3_nurseAccepted: null,
    step4_patientVisibleAcceptedOffer: null,
    step5_patientAcceptedAndBookingCreated: null,
    step6_requestFinalState: null,
  };

  // Step 1: customer creates matching request
  const createResp = await axios.post(
    `${baseUrl}/api/matching/request`,
    {
      serviceId: String(service._id),
      latitude: 30.0444,
      longitude: 31.2357,
      address: {
        street: 'Tahrir St',
        area: 'Downtown',
        city: 'Cairo',
        state: 'Cairo',
      },
      nurseGenderPreference: 'any',
      timeOption: 'asap',
      notes: 'E2E matching flow test',
    },
    {
      headers: {
        Authorization: `Bearer ${customerToken}`,
      },
    },
  );

  const requestId = createResp.data?.matchingRequest?.id;
  if (!requestId) {
    throw new Error('Step 1 failed: no matchingRequest.id returned');
  }

  stepResults.step1_createRequest = {
    ok: createResp.status === 201,
    requestId,
    matchedCount: createResp.data?.matchingRequest?.matchedCount,
    status: createResp.data?.matchingRequest?.status,
    message: createResp.data?.message,
  };

  // Step 2: verify pending offer exists and visible to nurse
  const dbOffer = await findOfferForRequest(requestId, nurse._id);
  if (!dbOffer) {
    throw new Error('Step 2 failed: no pending offer generated for ready nurse');
  }

  const nurseOffersResp = await axios.get(`${baseUrl}/api/matching/nurse-offers`, {
    headers: {
      Authorization: `Bearer ${nurseToken}`,
    },
  });

  const nurseOffers = nurseOffersResp.data?.offers || [];
  const nurseHasOffer = nurseOffers.some((o) => String(o.offerId) === String(dbOffer._id));
  if (!nurseHasOffer) {
    throw new Error('Step 2 failed: offer not visible in nurse offers endpoint');
  }

  stepResults.step2_nurseOfferVisible = {
    ok: true,
    offerId: String(dbOffer._id),
    nurseOffersCount: nurseOffersResp.data?.count,
  };

  // Step 3: nurse accepts offer
  const nurseAcceptResp = await axios.put(
    `${baseUrl}/api/matching/nurse-offers/${dbOffer._id}/respond`,
    { response: 'accepted' },
    {
      headers: {
        Authorization: `Bearer ${nurseToken}`,
      },
    },
  );

  stepResults.step3_nurseAccepted = {
    ok: nurseAcceptResp.status === 200,
    nurseStatus: nurseAcceptResp.data?.offer?.nurseStatus,
  };

  // Step 4: patient can see accepted offers
  const patientOffersResp = await axios.get(
    `${baseUrl}/api/matching/patient-offers/${requestId}`,
    {
      headers: {
        Authorization: `Bearer ${customerToken}`,
      },
    },
  );

  const patientOffers = patientOffersResp.data?.offers || [];
  const patientCanSeeOffer = patientOffers.some((o) => String(o.offerId) === String(dbOffer._id));
  if (!patientCanSeeOffer) {
    throw new Error('Step 4 failed: accepted offer not visible to patient');
  }

  stepResults.step4_patientVisibleAcceptedOffer = {
    ok: true,
    visibleOffersCount: patientOffersResp.data?.count,
  };

  // Step 5: patient accepts offer -> booking created
  const patientAcceptResp = await axios.put(
    `${baseUrl}/api/matching/patient-offers/${dbOffer._id}/respond`,
    { response: 'accepted' },
    {
      headers: {
        Authorization: `Bearer ${customerToken}`,
      },
    },
  );

  const bookingId = patientAcceptResp.data?.booking?.id;
  if (!bookingId) {
    throw new Error('Step 5 failed: booking was not created after patient acceptance');
  }

  stepResults.step5_patientAcceptedAndBookingCreated = {
    ok: true,
    bookingId,
    bookingStatus: patientAcceptResp.data?.booking?.status,
  };

  // Step 6: final request state verification
  const requestStatusResp = await axios.get(`${baseUrl}/api/matching/request/${requestId}`, {
    headers: {
      Authorization: `Bearer ${customerToken}`,
    },
  });

  const finalRequest = await MatchingRequest.findById(requestId).select('status bookingId acceptedOfferId').lean();

  stepResults.step6_requestFinalState = {
    ok: true,
    apiStatus: requestStatusResp.data?.matchingRequest?.status,
    dbStatus: finalRequest?.status,
    bookingIdInDb: finalRequest?.bookingId ? String(finalRequest.bookingId) : null,
    acceptedOfferIdInDb: finalRequest?.acceptedOfferId ? String(finalRequest.acceptedOfferId) : null,
  };

  console.log(
    JSON.stringify(
      {
        service: {
          id: String(service._id),
          name: service.name,
          category: service.category,
        },
        actors: {
          customerId: String(customer._id),
          nurseId: String(nurse._id),
          nurseUserId: String(nurseUser._id),
        },
        results: stepResults,
      },
      null,
      2,
    ),
  );
}

(async () => {
  try {
    await run();
    process.exitCode = 0;
  } catch (error) {
    if (error.response) {
      console.error(
        JSON.stringify(
          {
            status: error.response.status,
            data: error.response.data,
          },
          null,
          2,
        ),
      );
    } else {
      console.error(error.message);
    }
    process.exitCode = 1;
  } finally {
    try {
      await mongoose.disconnect();
    } catch (_) {
      // ignore disconnect errors
    }
  }
})();
