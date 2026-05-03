const mongoose = require('mongoose');
require('dotenv').config();

const clinicSchema = new mongoose.Schema({
    name: String,
    verificationStatus: String,
    verificationDocuments: [String],
    doctor: { type: mongoose.Schema.Types.ObjectId, ref: 'Doctor' }
});

const doctorSchema = new mongoose.Schema({
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }
});

const userSchema = new mongoose.Schema({
    name: String
});

const Clinic = mongoose.models.Clinic || mongoose.model('Clinic', clinicSchema);
const Doctor = mongoose.models.Doctor || mongoose.model('Doctor', doctorSchema);
const User = mongoose.models.User || mongoose.model('User', userSchema);

async function checkClinics() {
    try {
        const uri = process.env.DATABASE_URI;
        if (!uri) {
            console.error('DATABASE_URI is missing');
            process.exit(1);
        }
        await mongoose.connect(uri);
        console.log('Connected to MongoDB');

        const pendingClinics = await Clinic.find({ verificationStatus: 'pending' })
            .populate({
                path: 'doctor',
                populate: { path: 'user', select: 'name' }
            });

        console.log(`Found ${pendingClinics.length} pending clinics`);

        pendingClinics.forEach((clinic, index) => {
            console.log(`\nClinic ${index + 1}: ${clinic.name}`);
            console.log(`Doctor: ${clinic.doctor?.user?.name || 'Unknown'}`);
            console.log(`Verification Documents:`, JSON.stringify(clinic.verificationDocuments));
            if (!clinic.verificationDocuments || clinic.verificationDocuments.length === 0) {
                console.log('⚠️ NO DOCUMENTS FOUND IN DB FIELD "verificationDocuments"');
            }
        });

        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
}

checkClinics();
