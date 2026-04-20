const mongoose = require('mongoose');

const connectDB = async () => {
    try {
        const uri = process.env.DATABASE_URI;

        if (!uri) {
            console.error('Error: DATABASE_URI is missing in .env');
            return false;
        }

        const conn = await mongoose.connect(uri, {
            serverSelectionTimeoutMS: 10000,
        });
        console.log(`MongoDB Connected: ${conn.connection.host}`);
        return true;
    } catch (error) {
        console.error(`Error: ${error.message}`);

        const msg = String(error.message || '').toLowerCase();
        if (msg.includes('bad auth')) {
            console.error('Mongo hint: invalid MongoDB username/password in DATABASE_URI.');
        } else if (msg.includes('whitelist')) {
            console.error('Mongo hint: current machine IP is not whitelisted in MongoDB Atlas Network Access.');
        }

        return false;
    }
};
module.exports = connectDB;