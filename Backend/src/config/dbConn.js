const mongoose = require('mongoose');
const dns = require('dns');

// Use Google DNS to resolve MongoDB Atlas SRV records
dns.setServers(['8.8.8.8', '8.8.4.4']);

const connectDB = async () => {
    try {
        const conn = await mongoose.connect(process.env.DATABASE_URI, {
            serverSelectionTimeoutMS: 30000,
            socketTimeoutMS: 45000,
            family: 4, // Use IPv4, skip trying IPv6
        });
        console.log(`MongoDB Connected: ${conn.connection.host}`);
    } catch (error) {
        console.error(`MongoDB Connection Error: ${error.message}`);
        console.error('If DNS timeout persists, check your network or try a different DNS server');
    }
};
module.exports = connectDB;