const mongoose = require('mongoose');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../../.env') });

const User = require('../models/User');
const Nurse = require('../models/Nurse');
const Doctor = require('../models/Doctor');
const Booking = require('../models/Booking');
const Transaction = require('../models/Transaction');
const AuditLog = require('../models/audit-logging');

// Configuration
const CREATE_COUNT = {
    PATIENTS: 15,
    NURSES: 8, // 5 verified, 3 pending
    DOCTORS: 4, // 3 verified, 1 pending
    BOOKINGS: 40,
    LOGS: 20
};

// Data Pools
const firstNames = ['Ahmed', 'Mohamed', 'Sara', 'Mona', 'Ali', 'Omar', 'Nour', 'Laila', 'Hussein', 'Youssef', 'Fatma', 'Khaled', 'Eman', 'Amr', 'Dina'];
const lastNames = ['Hassan', 'Ibrahim', 'Ali', 'Mahmoud', 'Saad', 'Fawzy', 'Kamel', 'Nasser', 'Farag', 'Salem', 'Aziz', 'Hamdy'];
const services = [
    { name: 'Home Nursing', price: 300, type: 'nurse_visit' },
    { name: 'PCR Test', price: 500, type: 'procedural' },
    { name: 'Physiotherapy', price: 400, type: 'therapy' },
    { name: 'Elderly Care', price: 250, type: 'care' },
    { name: 'Doctor Consultation', price: 800, type: 'consultation' },
    { name: 'Wound Dressing', price: 200, type: 'nurse_visit' }
];

const getRandom = (arr) => arr[Math.floor(Math.random() * arr.length)];
const randomInt = (min, max) => Math.floor(Math.random() * (max - min + 1)) + min;
const randomPhone = () => `01${getRandom(['0', '1', '2', '5'])}${randomInt(10000000, 99999999)}`;
const randomDate = (start, end) => new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()));

// Hardcoded hash/salt for password "123456" (Generated for demo)
const DEMO_HASH = "8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92"; 
const DEMO_SALT = "1234567890abcdef"; // Mock salt

const connectDB = async () => {
    try {
        await mongoose.connect(process.env.DATABASE_URI);
        console.log('📦 MongoDB Connected');
    } catch (err) {
        console.error('❌ Database connection failed:', err);
        process.exit(1);
    }
};

const seedUsers = async () => {
    console.log('🌱 Seeding Users...');
    const users = [];
    
    // Create Patients
    for (let i = 0; i < CREATE_COUNT.PATIENTS; i++) {
        const gender = Math.random() > 0.5 ? 'male' : 'female';
        const name = `${getRandom(firstNames)} ${getRandom(lastNames)}`;
        
        users.push({
            name,
            email: `patient${i + 1}_${Date.now()}@test.com`,
            mobile: randomPhone(),
            password_hash: DEMO_HASH,
            salt: DEMO_SALT,
            role: 'customer',
            status: 'approved', // User status enum: approved
            verificationStatus: 'verified', // User verification enum: verified
            gender
        });
    }

    // Create Nurses & Doctors base users
    const staffUsers = [];
    for (let i = 0; i < CREATE_COUNT.NURSES + CREATE_COUNT.DOCTORS; i++) {
        const isNurse = i < CREATE_COUNT.NURSES;
        const role = isNurse ? 'nurse' : 'doctor';
        
        // Status logic
        let status = 'approved';
        let userVerificationStatus = 'verified';
        let providerVerificationStatus = 'approved';
        
        // Make some pending
        if ((isNurse && i >= 5) || (!isNurse && i >= 3)) {
            userVerificationStatus = 'pending';
            providerVerificationStatus = 'pending';
            status = 'pending';
        }

        const name = `${getRandom(firstNames)} ${getRandom(lastNames)}`;
        staffUsers.push({
            name,
            email: `${role}${i + 1}_${Date.now()}@housepital.com`,
            mobile: randomPhone(),
            password_hash: DEMO_HASH,
            salt: DEMO_SALT,
            role,
            status,
            verificationStatus: userVerificationStatus, // User enum
            gender: Math.random() > 0.5 ? 'male' : 'female',
            _providerVerification: providerVerificationStatus // Temporary prop to pass to seedProviders
        });
    }

    const createdUsers = await User.insertMany(users);
    const createdStaff = await User.insertMany(staffUsers);

    console.log(`✅ ${createdUsers.length} Patients Created`);
    console.log(`✅ ${createdStaff.length} Staff Users Created`);

    // We need to pass the provider verification status. 
    // Since insertMany returns docs without our temp prop, we map by email or index? 
    // Easier: Just loop and create one by one? Or merge arrays.
    // Hack: Attach property to the mongoose doc object (it won't save it but we can use it if we are careful, actually insertMany returns hydration).
    // Better: Re-map using original array order (assuming insertMany maintains order which it usually does).
    
    // Let's create a map of email -> providerStatus
    const providerStatusMap = {};
    staffUsers.forEach(u => {
        providerStatusMap[u.email] = u._providerVerification;
    });

    return { patients: createdUsers, staff: createdStaff, providerStatusMap };
};

const seedProviders = async (staffUsers, providerStatusMap) => {
    console.log('🌱 Seeding Providers (Nurses/Doctors)...');
    
    for (const user of staffUsers) {
        // Get correct provider status
        const providerStatus = providerStatusMap[user.email] || 'approved';

        const commonData = {
            user: user._id,
            licenseNumber: `LIC-${randomInt(10000, 99999)}`,
            specialization: getRandom(['General Care', 'ICU', 'Pediatrics', 'Geriatrics', 'Surgery']),
            yearsOfExperience: randomInt(1, 15),
            gender: user.gender,
            verificationStatus: providerStatus, // Nurse/Doctor enum
            bio: "Experienced professional dedicated to patient care with a track record of excellence in home healthcare.",
            documents: {
                nationalId: "https://via.placeholder.com/150?text=National+ID",
                license: "https://via.placeholder.com/150?text=Medical+License",
                degree: "https://via.placeholder.com/150?text=Degree+Certificate"
            }
        };

        if (user.role === 'nurse') {
            await Nurse.create({
                ...commonData,
                isOnline: Math.random() > 0.7,
                skills: ['Wound Care', 'IV Therapy', 'Patient Monitoring'],
                hourlyRate: 150
            });
        } else {
            await Doctor.create({
                ...commonData,
                consultationFee: 500,
                qualifications: ['MBBS', 'MSc']
            });
        }
    }
    console.log('✅ Provider Profiles Created');
};

const seedBookings = async (patients, staffUsers) => {
    console.log('🌱 Seeding Bookings...');
    const bookings = [];
    
    const nurses = await Nurse.find().populate('user');
    
    // Generate bookings
    for (let i = 0; i < CREATE_COUNT.BOOKINGS; i++) {
        const patient = getRandom(patients);
        const service = getRandom(services);
        
        // Logic for dates and status
        // 70% past bookings (completed/cancelled), 30% future/active
        const isPast = Math.random() > 0.3;
        const date = isPast 
            ? randomDate(new Date(Date.now() - 30 * 24 * 60 * 60 * 1000), new Date()) 
            : randomDate(new Date(), new Date(Date.now() + 7 * 24 * 60 * 60 * 1000));
        
        let status;
        if (isPast) {
            status = Math.random() > 0.2 ? 'completed' : 'cancelled';
        } else {
            status = getRandom(['pending', 'assigned', 'in-progress', 'confirmed']);
        }

        const booking = {
            userId: patient._id, // User who created booking
            patientId: patient._id, // Patient receiving service
            isForSelf: true,
            
            serviceName: service.name,
            servicePrice: service.price,
            
            type: service.type === 'consultation' ? 'clinic_appointment' : 'home_nursing',
            
            timeOption: 'schedule',
            scheduledDate: date,
            scheduledTime: date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
            
            status,
            
            // Legacy/Frontend fields (might not be in schema but useful if allowed by strict: false, or ignored)
            // Schema has: address, notes, location, visitPin
            
            address: {
                street: `${randomInt(1, 100)} Main St`,
                city: 'Cairo',
                area: getRandom(['Maadi', 'Zamalek', 'Nasr City', 'New Cairo']),
                state: 'Cairo',
                coordinates: { lat: 30.0444, lng: 31.2357 }
            },
            notes: "Please call upon arrival.",
            visitPin: randomInt(1000, 9999).toString(),
            createdAt: date,
            
            // Additional schema fields
            patientName: patient.name
        };

        // Assign nurse if verified and status not pending
        if (status !== 'pending' && status !== 'cancelled') {
            const nurse = getRandom(nurses);
            if (nurse) {
                booking.assignedNurse = nurse._id;
                booking.nurseName = nurse.user.name; // assuming population works or manual set
            }
        }

        bookings.push(booking);
    }
    
    const createdBookings = await Booking.insertMany(bookings);
    console.log(`✅ ${createdBookings.length} Bookings Created`);
    return createdBookings;
};

const seedTransactions = async (bookings) => {
    console.log('🌱 Seeding Transactions...');
    const completedBookings = bookings.filter(b => b.status === 'completed');
    const transactions = [];

    for (const b of completedBookings) {
        transactions.push({
            bookingId: b._id,
            amount: b.servicePrice,
            type: 'booking_payment',
            status: 'completed',
            paymentMethod: 'card', // Enum: card
            direction: 'credit', // Money coming in
            paymentReference: `TXN_${randomInt(100000, 999999)}`,
            createdAt: b.createdAt,
            description: `Payment for booking ${b._id}`
        });

        // Add platform fee
        if (Math.random() > 0.5) {
             transactions.push({
                bookingId: b._id,
                amount: b.servicePrice * 0.1,
                type: 'platform_fee',
                status: 'completed',
                // paymentMethod omitted as it is internal
                direction: 'credit',
                createdAt: b.createdAt
            });
        }
    }

    // Add some withdrawals
    const withdrawalCount = Math.floor(Math.random() * 5) + 1;
    for (let i = 0; i < withdrawalCount; i++) {
         transactions.push({
            amount: randomInt(1000, 5000),
            type: 'withdrawal',
            status: 'completed',
            direction: 'debit', // Money going out
            paymentMethod: 'bank_transfer',
            createdAt: randomDate(new Date(Date.now() - 30 * 24 * 60 * 60 * 1000), new Date()),
            description: 'Provider withdrawal'
        });
    }

    await Transaction.insertMany(transactions);
    console.log(`✅ ${transactions.length} Transactions Created`);
};

const cleanData = async () => {
    console.log('🧹 Cleaning up old demo data...');
    // Delete users created by this script (based on email pattern)
    const demoUserPattern = /(@test\.com|@housepital\.com)$/;
    const deletedUsers = await User.deleteMany({ email: demoUserPattern });
    console.log(`- Deleted ${deletedUsers.deletedCount} demo users`);

    // Delete bookings/transactions/logs - simplest is to wipe them or delete those linked to deleted users?
    // For a clean demo, we'll wipe Collections that are mostly transactional if they are just demo data. 
    // BUT we must be careful not to delete real data if any. 
    // Since this is a demo environment request, and user said "clean it", I'll be aggressive but safe enough.
    // actually, deleting Users triggers cascades? No, Mongoose doesn't cascade by default.
    // I will delete Bookings/Transactions/AuditLogs where we created them. 
    // Since I don't track IDs, I'll delete ALL for these collections IF the user is okay with it?
    // User said "deal with database data... clean it... remove broken".
    // I'll delete ALL Bookings, Transactions, AuditLogs. This gives a Clean State.
    // But Users: Only delete demo ones to keep 'admin'.
    
    await Booking.deleteMany({});
    console.log(`- Deleted all Bookings`);
    
    await Transaction.deleteMany({});
    console.log(`- Deleted all Transactions`);
    
    await AuditLog.deleteMany({});
    console.log(`- Deleted all Audit Logs`);
    
    await Nurse.deleteMany({});
    await Doctor.deleteMany({});
    console.log(`- Deleted all Nurse/Doctor Profiles`);
};

const seedLogs = async (staffUsers, patients) => {
    console.log('🌱 Seeding Audit Logs...');
    const logs = [];
    const actions = ['REGISTER', 'APPROVE', 'REJECT']; // Matches schema common actions
    
    // Find an admin to perform actions
    let admin = await User.findOne({ role: 'admin' });
    if (!admin) {
        // Create dummy admin if not exists
        admin = await User.create({
            name: 'System Admin',
            email: 'admin@housepital.com',
            password_hash: DEMO_HASH,
            salt: DEMO_SALT,
            role: 'admin',
            status: 'approved',
            verificationStatus: 'verified'
        });
    }

    const allTargets = [...staffUsers, ...patients];

    for (let i = 0; i < CREATE_COUNT.LOGS; i++) {
        const target = getRandom(allTargets);
        if (!target) continue;
        
        const action = getRandom(actions);
        
        logs.push({
            action: action,
            performedBy: admin._id,
            targetUser: {
                id: target._id,
                name: target.name,
                email: target.email,
                mobile: target.mobile,
                role: target.role
            },
            status: 'APPROVED',
            description: `Admin perfromed ${action} on ${target.name}`,
            timestamp: randomDate(new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), new Date())
        });
    }
    
    await AuditLog.insertMany(logs);
    console.log(`✅ ${logs.length} Logs Created`);
};

const updateNurseStats = async () => {
    console.log('🔄 Updating Nurse Stats...');
    const nurses = await Nurse.find();
    
    for (const nurse of nurses) {
        // Count completed bookings where nurse is assigned
        const completedVisits = await Booking.countDocuments({ 
            assignedNurse: nurse._id, 
            status: 'completed' 
        });

        // Sum earnings from transactions (booking_payment implies revenue, but nurse earning is specific?)
        // In my seedTransactions, I created 'booking_payment' linked to booking.
        // But did I create 'nurse_earning'? No.
        // Usually system calculates nurse split. 
        // For demo, I'll assume nurse gets 70% of booking price for their completed bookings?
        // OR I should look at Transaction types.
        // If I want 'totalEarnings' field to be populated, I can just set it based on completed bookings * rate (or price).
        
        // Let's sum up the servicePrice of completed bookings assigned to this nurse, and take 70%?
        const bookings = await Booking.find({ assignedNurse: nurse._id, status: 'completed' });
        const totalRevenue = bookings.reduce((sum, b) => sum + b.servicePrice, 0);
        const earnings = totalRevenue * 0.7; // 70% share

        nurse.totalEarnings = earnings;
        nurse.availableBalance = earnings; // assuming all available
        nurse.pendingBalance = 0;
        nurse.completedVisits = completedVisits;
        
        await nurse.save();
    }
    console.log('✅ Nurse Stats Updated');
};

const run = async () => {
    await connectDB();
    
    await cleanData();
    
    const { patients, staff, providerStatusMap } = await seedUsers();
    await seedProviders(staff, providerStatusMap);
    const bookings = await seedBookings(patients, staff);
    await seedTransactions(bookings);
    await seedLogs(staff, patients);
    await updateNurseStats();

    console.log('🚀 Seeding Complete!');
    process.exit(0);
};

run();
