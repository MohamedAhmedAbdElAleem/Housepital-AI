const mongoose = require('mongoose');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });
const connectDB = require('./src/config/dbConn');
const Doctor = require('./src/models/Doctor');

const approveDoctors = async () => {
    try {
        await connectDB();
        
        console.log("Checking doctors...");
        const doctors = await Doctor.find({});
        console.log(`Found ${doctors.length} doctors.`);
        
        for (let doc of doctors) {
            console.log(`Doctor ${doc._id}: Status = ${doc.verificationStatus}`);
            if (doc.verificationStatus !== 'approved') {
                doc.verificationStatus = 'approved';
                await doc.save();
                console.log(`✅ Approved doctor ${doc._id}`);
            }
        }
        
        console.log("Done.");
        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
};

approveDoctors();
