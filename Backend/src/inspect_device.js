const mongoose = require('mongoose');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });
const Device = require('./models/Device');
const Booking = require('./models/Booking');
const crypto = require('crypto');

const inspect = async () => {
    try {
        await mongoose.connect(process.env.DATABASE_URI);
        console.log('Connected to DB');

        const deviceId = 'HOSP-NODE-001';
        const device = await Device.findOne({ deviceId });
        
        if (!device) {
            console.log(`Device ${deviceId} not found`);
        } else {
            console.log('--- Device Info ---');
            console.log('ID:', device.deviceId);
            console.log('Status:', device.status);
            console.log('Assigned Booking:', device.assignedBooking);
            console.log('Last Seen:', device.lastSeenAt);
            console.log('Token Hash in DB:', device.deviceTokenHash);
            
            const providedToken = '5643026179247735d0574093517c0a8ee0af1c3ec5dd15388c29a7e3145d900c';
            const providedHash = crypto.createHash('sha256').update(providedToken).digest('hex');
            console.log('Hash of token in pin_config.h:', providedHash);
            console.log('Matches?', device.deviceTokenHash === providedHash);
        }

        const bookingId = '6a06fa2fb212a9ee263fda8a';
        try {
            const booking = await Booking.findById(bookingId);
            if (!booking) {
                console.log(`Booking ${bookingId} not found`);
            } else {
                console.log('--- Booking Info ---');
                console.log('ID:', booking._id);
                console.log('Status:', booking.status);
                console.log('Assigned Nurse:', booking.assignedNurse);
            }
        } catch (err) {
            console.log(`Error finding booking ${bookingId}:`, err.message);
        }

        await mongoose.connection.close();
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
};

inspect();
