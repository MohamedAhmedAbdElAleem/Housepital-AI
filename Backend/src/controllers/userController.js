const User = require('../models/User');
const { logEvents } = require('../middleware/logger');
const jwt = require('jsonwebtoken');
const { createRedisClient } = require('../caching/redis');
const redis = createRedisClient();
const bcrypt = require('bcryptjs');


exports.updateInfo = async (req, res) => {
  try {
    const id = req.body.id;
    const data = req.body;

    const fields = Object.keys(User.schema.paths).filter(f => !["_id", "__v"].includes(f));

    const updateData = {};
    for (const key in data) {
      if (fields.includes(key)) {
        updateData[key] = data[key];
      }
    }

    if ("password" in data) {
        const password = data.password;
        const salt = await bcrypt.genSalt(12);
        updateData.password_hash = await bcrypt.hash(password, salt);
        updateData.salt = salt;
        delete updateData.password;
    }


    const updatedUser = await User.findByIdAndUpdate(
      id,
      { $set: updateData },
      { new: true, runValidators: true }
    );

    return res.status(200).json(updatedUser);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Something went wrong" });
  }
};


exports.getUserinfo = async (req, res) => {
    try {
        const id = req.body.id;
        if (!id) return res.status(400).json({ message: "No ID provided" });

        const user = await User.findById(id);

        if (!user) return res.status(404).json({ message: "User not found" });

        return res.status(200).json(user);
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: "Something went wrong" });
    }
};

/**
 * @desc    Update user profile (name, email, mobile)
 * @route   PUT /api/users/update-profile
 * @access  Private
 */
exports.updateProfile = async (req, res) => {
    try {
        const { name, email, mobile } = req.body;
        const userId = req.user.id;

        // Validate inputs
        if (!name || !email || !mobile) {
            return res.status(400).json({
                success: false,
                message: 'Name, email, and mobile are required'
            });
        }

        // Convert email to lowercase
        const emailLowerCase = email.toLowerCase();

        // Check if email is already used by another user
        const existingUser = await User.findOne({
            email: emailLowerCase,
            _id: { $ne: userId }
        });

        if (existingUser) {
            return res.status(400).json({
                success: false,
                message: 'Email is already in use by another account'
            });
        }

        // Check if mobile is already used by another user
        const existingMobile = await User.findOne({
            mobile: mobile,
            _id: { $ne: userId }
        });

        if (existingMobile) {
            return res.status(400).json({
                success: false,
                message: 'Mobile number is already in use by another account'
            });
        }

        // Update user
        const user = await User.findByIdAndUpdate(
            userId,
            {
                name: name.trim(),
                email: emailLowerCase,
                mobile: mobile.trim()
            },
            { new: true, runValidators: true }
        );

        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        // Log the update
        logEvents(
            `User profile updated: ${user.email}`,
            'userLog.log'
        );

        res.status(200).json({
            success: true,
            message: 'Profile updated successfully',
            user: user.toJSON()
        });

    } catch (error) {
        logEvents(
            `Update profile error: ${error.message}`,
            'userErrLog.log'
        );

        res.status(500).json({
            success: false,
            message: error.message || 'Error updating profile'
        });
    }
};
