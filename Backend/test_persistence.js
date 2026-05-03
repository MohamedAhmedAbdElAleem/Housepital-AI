const mongoose = require('mongoose');
const Clinic = require('./src/models/Clinic');
const Doctor = require('./src/models/Doctor');
const User = require('./src/models/User');
require('dotenv').config();

async function testClinicCreation() {
    try {
        const uri = process.env.DATABASE_URI;
        await mongoose.connect(uri);
        console.log('Connected to MongoDB');

        // Find a doctor to associate with
        const doctor = await Doctor.findOne();
        if (!doctor) {
            console.log('No doctor found to test with');
            process.exit(1);
        }

        const clinicData = {
            doctor: doctor._id,
            name: "Test Document Clinic",
            address: {
                street: "123 Test St",
                city: "test city",
                state: "test state"
            },
            verificationDocuments: ["https://example.com/doc1.pdf", "https://example.com/doc2.jpg"]
        };

        const clinic = new Clinic(clinicData);
        await clinic.save();
        console.log('Clinic saved with documents:', clinic.verificationDocuments);

        const fetched = await Clinic.findById(clinic._id);
        console.log('Fetched clinic documents:', fetched.verificationDocuments);

        if (fetched.verificationDocuments.length === 2) {
            console.log('✅ PERSISTENCE WORKING IN MONGOOSE MODEL');
        } else {
            console.log('❌ PERSISTENCE FAILED');
        }

        // Clean up
        await Clinic.deleteOne({ _id: clinic._id });
        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
}

testClinicCreation();
