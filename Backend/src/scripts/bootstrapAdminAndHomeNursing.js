/* eslint-disable no-console */
require('dotenv').config();
const mongoose = require('mongoose');

const User = require('../models/User');
const Nurse = require('../models/Nurse');
const Service = require('../models/Service');

const ADMIN_EMAIL = 'admin@gmail.com';
const ADMIN_PASSWORD = '111111';
const ADMIN_NAME = 'Housepital Admin';

const HOME_NURSING_SERVICES = [
  {
    category: 'wound_care',
    name: 'Wound Care',
    description: 'Professional wound care and dressing services provided by certified nurses.',
    price: 150,
    durationMinutes: 40,
    requiresTools: true,
  },
  {
    category: 'injections',
    name: 'Injections',
    description: 'Safe and painless injection services at your home.',
    price: 50,
    durationMinutes: 20,
    requiresTools: false,
  },
  {
    category: 'elderly_care',
    name: 'Elderly Care',
    description: 'Comprehensive care for elderly patients including assistance with daily activities.',
    price: 200,
    durationMinutes: 120,
    requiresTools: false,
  },
  {
    category: 'post_op_care',
    name: 'Post-Op Care',
    description: 'Post-operative care services to ensure smooth recovery after surgery.',
    price: 300,
    durationMinutes: 55,
    requiresTools: true,
  },
  {
    category: 'baby_care',
    name: 'Baby Care',
    description: 'Professional newborn and infant care services.',
    price: 180,
    durationMinutes: 150,
    requiresTools: false,
  },
  {
    category: 'iv_therapy',
    name: 'IV Therapy',
    description: 'Intravenous fluid and medication therapy administered safely at home.',
    price: 250,
    durationMinutes: 55,
    requiresTools: true,
  },
  {
    category: 'catheter_care',
    name: 'Catheter Care',
    description: 'Professional catheter insertion, maintenance, and care services.',
    price: 120,
    durationMinutes: 35,
    requiresTools: true,
  },
  {
    category: 'vital_signs',
    name: 'Vital Signs',
    description: 'Complete vital signs monitoring with detailed reporting.',
    price: 80,
    durationMinutes: 25,
    requiresTools: false,
  },
  {
    category: 'blood_draw',
    name: 'Blood Draw',
    description: 'Professional blood sample collection at your home.',
    price: 100,
    durationMinutes: 15,
    requiresTools: true,
  },
  {
    category: 'physiotherapy',
    name: 'Physiotherapy',
    description: 'Home physiotherapy sessions for rehabilitation and mobility.',
    price: 350,
    durationMinutes: 75,
    requiresTools: false,
  },
];

async function generateUniqueEgyptMobile() {
  const prefixes = ['010', '011', '012', '015'];

  for (let attempt = 0; attempt < 5000; attempt += 1) {
    const prefix = prefixes[attempt % prefixes.length];
    const suffix = String(Math.floor(Math.random() * 100000000)).padStart(8, '0');
    const mobile = `${prefix}${suffix}`;
    const exists = await User.exists({ mobile });

    if (!exists) return mobile;
  }

  throw new Error('Unable to generate a unique Egyptian mobile number for admin user');
}

function isValidEgyptMobile(mobile) {
  return /^01[0125][0-9]{8}$/.test(String(mobile || ''));
}

async function ensureAdminUser() {
  const email = ADMIN_EMAIL.toLowerCase().trim();
  let user = await User.findOne({ email }).select('+password_hash');
  const created = !user;

  if (!user) {
    user = new User({
      name: ADMIN_NAME,
      email,
      mobile: await generateUniqueEgyptMobile(),
      password_hash: ADMIN_PASSWORD,
      role: 'admin',
      isVerified: true,
      status: 'approved',
      verificationStatus: 'verified',
    });
  } else {
    if (!isValidEgyptMobile(user.mobile)) {
      user.mobile = await generateUniqueEgyptMobile();
    }

    if (!user.name || user.name.trim().length < 2) {
      user.name = ADMIN_NAME;
    }

    user.role = 'admin';
    user.isVerified = true;
    user.status = 'approved';
    user.verificationStatus = 'verified';

    // Set the requested login password every time this bootstrap runs.
    user.password_hash = ADMIN_PASSWORD;
  }

  await user.save();

  return {
    created,
    id: user._id.toString(),
    email: user.email,
    mobile: user.mobile,
  };
}

async function findSeedProviderNurse() {
  let nurse = await Nurse.findOne({ profileStatus: 'approved' }).sort({ updatedAt: -1 });

  if (!nurse) {
    nurse = await Nurse.findOne({}).sort({ updatedAt: -1 });
  }

  if (!nurse) {
    throw new Error('No nurse profile found to attach home nursing services. Create at least one nurse first.');
  }

  return nurse;
}

async function upsertHomeNursingServices(providerNurseId) {
  let created = 0;
  let updated = 0;

  for (const item of HOME_NURSING_SERVICES) {
    const filter = {
      type: 'home_nursing',
      category: item.category,
      providerModel: 'Nurse',
      providerId: providerNurseId,
    };

    const payload = {
      name: item.name,
      description: item.description,
      price: item.price,
      durationMinutes: item.durationMinutes,
      requiresTools: item.requiresTools,
      currency: 'EGP',
      isActive: true,
      type: 'home_nursing',
      category: item.category,
      providerModel: 'Nurse',
      providerId: providerNurseId,
    };

    const existing = await Service.findOne(filter);

    if (existing) {
      existing.set(payload);
      await existing.save();
      updated += 1;
    } else {
      await Service.create(payload);
      created += 1;
    }
  }

  return { created, updated, totalTarget: HOME_NURSING_SERVICES.length };
}

async function main() {
  if (!process.env.DATABASE_URI) {
    throw new Error('DATABASE_URI is missing in Backend/.env');
  }

  await mongoose.connect(process.env.DATABASE_URI, {
    serverSelectionTimeoutMS: 15000,
  });

  const admin = await ensureAdminUser();
  const nurse = await findSeedProviderNurse();
  const serviceResult = await upsertHomeNursingServices(nurse._id);

  console.log('');
  console.log('Bootstrap completed successfully');
  console.log(`Admin: ${admin.created ? 'created' : 'updated'} (${admin.email}) id=${admin.id}`);
  console.log(`Provider nurse: ${nurse._id.toString()}`);
  console.log(`Services: created=${serviceResult.created}, updated=${serviceResult.updated}, target=${serviceResult.totalTarget}`);
}

(async () => {
  try {
    await main();
    process.exitCode = 0;
  } catch (error) {
    console.error('Bootstrap failed:', error.message);
    process.exitCode = 1;
  } finally {
    try {
      await mongoose.disconnect();
    } catch (disconnectError) {
      console.error('Mongo disconnect warning:', disconnectError.message);
    }
  }
})();
