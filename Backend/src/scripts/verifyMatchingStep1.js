/* eslint-disable no-console */
require('dotenv').config();
const mongoose = require('mongoose');
const jwt = require('jsonwebtoken');
const axios = require('axios');

const User = require('../models/User');
const Service = require('../models/Service');

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

  return user;
}

async function run() {
  if (!process.env.DATABASE_URI) {
    throw new Error('DATABASE_URI is missing');
  }

  await mongoose.connect(process.env.DATABASE_URI, {
    serverSelectionTimeoutMS: 10000,
  });

  const user = await ensureTestCustomer();
  const service = await Service.findOne({ type: 'home_nursing', isActive: true })
    .select('_id name category')
    .lean();

  if (!service) {
    throw new Error('No active home_nursing service found');
  }

  const token = jwt.sign(
    {
      id: String(user._id),
      email: user.email,
      role: 'customer',
    },
    process.env.JWT_SECRET_KEY || 'housepital_secret_key_2024',
    { expiresIn: '1h' },
  );

  const baseUrl = `http://127.0.0.1:${process.env.PORT || 3500}`;
  const payload = {
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
    notes: 'Step1 matching test request',
  };

  const response = await axios.post(`${baseUrl}/api/matching/request`, payload, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  const result = {
    status: response.status,
    message: response.data?.message,
    service: {
      id: String(service._id),
      name: service.name,
      category: service.category,
    },
    matchingRequest: response.data?.matchingRequest || null,
  };

  console.log(JSON.stringify(result, null, 2));
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
