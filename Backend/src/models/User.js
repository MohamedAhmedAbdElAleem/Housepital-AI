const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

const userSchema = new mongoose.Schema(
    {
        name: {
            type: String,
            required: [true, 'Please provide a name'],
            trim: true,
            minlength: [2, 'Name must be at least 2 characters'],
            maxlength: [50, 'Name cannot exceed 50 characters']
        },
        email: {
            type: String,
            required: [true, 'Please provide an email'],
            unique: true,
            lowercase: true,
            match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Please provide a valid email address']
        },
        mobile: {
            type: String,
            required: [true, 'Please provide a mobile number'],
            unique: true,
            match: [/^[0-9]{10,15}$/, 'Please provide a valid mobile number']
        },
        password_hash: {
            type: String,
            required: [true, 'Please provide a password'],
            minlength: [8, 'Password must be at least 8 characters'],
            select: false // Don't include password in queries by default
        },
        salt: {
            type: String,
            select: false // Store salt for reference
        },
        hashingAlgorithm: {
            type: String,
            default: 'bcrypt',
            select: false
        },
        costFactor: {
            type: Number,
            default: 12, // bcrypt cost factor
            select: false
        },
        isVerified: {
            type: Boolean,
            default: false
        },
        role: {
            type: String,
            enum: ['customer', 'doctor', 'admin'],
            default: 'customer'
        },
        resetOTP: {
            type: String,
            select: false
        },
        otpExpires: {
            type: Date,
            select: false
        },
        otpAttempts: {
            type: Number,
            default: 0,
            select: false
        }
    },
    {
        timestamps: true
    }
);

// Hash password before saving
userSchema.pre('save', async function(next) {
    if (!this.isModified('password_hash')) {
        return next();
    }

    try {
        // Generate salt and hash password with bcrypt (cost factor 12)
        const salt = await bcrypt.genSalt(12);
        this.password_hash = await bcrypt.hash(this.password_hash, salt);
        this.salt = salt;
        this.hashingAlgorithm = 'bcrypt';
        this.costFactor = 12;
        next();
    } catch (error) {
        next(error);
    }
});

// Method to compare password with stored hash
userSchema.methods.comparePassword = async function(enteredPassword) {
    return await bcrypt.compare(enteredPassword, this.password_hash);
};

// Prevent logging sensitive data
userSchema.methods.toJSON = function() {
    const userObj = this.toObject();
    delete userObj.password_hash;
    delete userObj.salt;
    delete userObj.hashingAlgorithm;
    delete userObj.costFactor;
    return userObj;
};

module.exports = mongoose.model('User', userSchema);
