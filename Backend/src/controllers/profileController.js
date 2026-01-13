const User = require('../models/User');
const { logEvents } = require('../middleware/logger');
const path = require('path');
const fs = require('fs');

/**
 * @desc    Update user's medical information
 * @route   PUT /api/profile/medical-info
 * @access  Private
 */
exports.updateMedicalInfo = async (req, res) => {
    try {
        const userId = req.user.id;
        const {
            bloodType,
            chronicDiseases,
            allergies,
            otherConditions,
            currentMedications,
            hasNoChronicDiseases,
            hasNoAllergies
        } = req.body;

        // Build medical info object
        const medicalInfo = {
            updatedAt: new Date()
        };

        // Blood type validation
        if (bloodType !== undefined) {
            const validBloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', null];
            if (!validBloodTypes.includes(bloodType)) {
                return res.status(400).json({
                    success: false,
                    message: 'Invalid blood type'
                });
            }
            medicalInfo.bloodType = bloodType;
        }

        // Chronic diseases
        if (chronicDiseases !== undefined) {
            if (!Array.isArray(chronicDiseases)) {
                return res.status(400).json({
                    success: false,
                    message: 'Chronic diseases must be an array'
                });
            }
            medicalInfo.chronicDiseases = chronicDiseases.filter(d => d && d.trim());
        }

        // Allergies
        if (allergies !== undefined) {
            if (!Array.isArray(allergies)) {
                return res.status(400).json({
                    success: false,
                    message: 'Allergies must be an array'
                });
            }
            medicalInfo.allergies = allergies.filter(a => a && a.trim());
        }

        // Other conditions
        if (otherConditions !== undefined) {
            medicalInfo.otherConditions = otherConditions ? otherConditions.trim() : '';
        }

        // Current medications
        if (currentMedications !== undefined) {
            medicalInfo.currentMedications = currentMedications ? currentMedications.trim() : '';
        }

        // Boolean flags
        if (hasNoChronicDiseases !== undefined) {
            medicalInfo.hasNoChronicDiseases = Boolean(hasNoChronicDiseases);
        }

        if (hasNoAllergies !== undefined) {
            medicalInfo.hasNoAllergies = Boolean(hasNoAllergies);
        }

        // Update user's medical info
        const updatedUser = await User.findByIdAndUpdate(
            userId,
            { $set: { medicalInfo } },
            { new: true, runValidators: true }
        );

        if (!updatedUser) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        // Log the update
        logEvents(
            `Medical info updated for user: ${updatedUser.email}`,
            'profileLog.log'
        );

        res.status(200).json({
            success: true,
            message: 'Medical information updated successfully',
            medicalInfo: updatedUser.medicalInfo
        });

    } catch (error) {
        logEvents(
            `Medical info update error: ${error.message}`,
            'profileErrLog.log'
        );

        res.status(500).json({
            success: false,
            message: error.message || 'Error updating medical information'
        });
    }
};

/**
 * @desc    Get user's medical information
 * @route   GET /api/profile/medical-info
 * @access  Private
 */
exports.getMedicalInfo = async (req, res) => {
    try {
        const userId = req.user.id;

        const user = await User.findById(userId).select('medicalInfo');

        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        res.status(200).json({
            success: true,
            medicalInfo: user.medicalInfo || {}
        });

    } catch (error) {
        res.status(500).json({
            success: false,
            message: error.message || 'Error fetching medical information'
        });
    }
};

/**
 * @desc    Upload ID document (front or back)
 * @route   POST /api/profile/upload-id
 * @access  Private
 */
exports.uploadIdDocument = async (req, res) => {
    try {
        const userId = req.user.id;
        const { side, imageBase64 } = req.body;

        // Validate side
        if (!side || !['front', 'back'].includes(side)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid side. Must be "front" or "back"'
            });
        }

        // Validate image
        if (!imageBase64) {
            return res.status(400).json({
                success: false,
                message: 'Image data is required'
            });
        }

        // Create uploads directory if it doesn't exist
        const uploadsDir = path.join(__dirname, '../../uploads/id-documents');
        if (!fs.existsSync(uploadsDir)) {
            fs.mkdirSync(uploadsDir, { recursive: true });
        }

        // Generate unique filename
        const timestamp = Date.now();
        const filename = `${userId}_${side}_${timestamp}.jpg`;
        const filepath = path.join(uploadsDir, filename);

        // Remove base64 header if present
        const base64Data = imageBase64.replace(/^data:image\/\w+;base64,/, '');
        
        // Save image to file
        fs.writeFileSync(filepath, Buffer.from(base64Data, 'base64'));

        // Generate URL (relative path for now, can be changed to cloud storage URL)
        const imageUrl = `/uploads/id-documents/${filename}`;

        // Update user's ID document URL
        const updateField = side === 'front' ? 'idFrontImageUrl' : 'idBackImageUrl';
        
        const updateData = {
            [updateField]: imageUrl
        };

        // If both sides are uploaded, update verification status to pending
        const user = await User.findById(userId);
        const otherSide = side === 'front' ? 'idBackImageUrl' : 'idFrontImageUrl';
        
        if (user[otherSide]) {
            updateData.verificationStatus = 'pending';
        }

        const updatedUser = await User.findByIdAndUpdate(
            userId,
            { $set: updateData },
            { new: true }
        );

        if (!updatedUser) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        // Log the upload
        logEvents(
            `ID ${side} uploaded for user: ${updatedUser.email}`,
            'profileLog.log'
        );

        res.status(200).json({
            success: true,
            message: `ID ${side} uploaded successfully`,
            imageUrl: imageUrl,
            verificationStatus: updatedUser.verificationStatus
        });

    } catch (error) {
        logEvents(
            `ID upload error: ${error.message}`,
            'profileErrLog.log'
        );

        res.status(500).json({
            success: false,
            message: error.message || 'Error uploading ID document'
        });
    }
};

/**
 * @desc    Get user's verification status
 * @route   GET /api/profile/verification-status
 * @access  Private
 */
exports.getVerificationStatus = async (req, res) => {
    try {
        const userId = req.user.id;

        const user = await User.findById(userId).select(
            'verificationStatus idFrontImageUrl idBackImageUrl rejectionReason'
        );

        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        res.status(200).json({
            success: true,
            verificationStatus: user.verificationStatus,
            hasFrontId: !!user.idFrontImageUrl,
            hasBackId: !!user.idBackImageUrl,
            rejectionReason: user.rejectionReason || null
        });

    } catch (error) {
        res.status(500).json({
            success: false,
            message: error.message || 'Error fetching verification status'
        });
    }
};

/**
 * @desc    Complete profile setup (medical info + ID verification)
 * @route   POST /api/profile/complete-setup
 * @access  Private
 */
exports.completeProfileSetup = async (req, res) => {
    try {
        const userId = req.user.id;
        const {
            // Medical Info
            bloodType,
            chronicDiseases,
            allergies,
            otherConditions,
            currentMedications,
            hasNoChronicDiseases,
            hasNoAllergies,
            // ID Documents
            idFrontImage,
            idBackImage
        } = req.body;

        const updateData = {
            profileCompletedAt: new Date()
        };

        // Build medical info
        const medicalInfo = {
            updatedAt: new Date()
        };

        if (bloodType) medicalInfo.bloodType = bloodType;
        if (chronicDiseases) medicalInfo.chronicDiseases = chronicDiseases;
        if (allergies) medicalInfo.allergies = allergies;
        if (otherConditions) medicalInfo.otherConditions = otherConditions;
        if (currentMedications) medicalInfo.currentMedications = currentMedications;
        if (hasNoChronicDiseases !== undefined) medicalInfo.hasNoChronicDiseases = hasNoChronicDiseases;
        if (hasNoAllergies !== undefined) medicalInfo.hasNoAllergies = hasNoAllergies;

        updateData.medicalInfo = medicalInfo;

        // Handle ID images if provided
        if (idFrontImage || idBackImage) {
            const uploadsDir = path.join(__dirname, '../../uploads/id-documents');
            if (!fs.existsSync(uploadsDir)) {
                fs.mkdirSync(uploadsDir, { recursive: true });
            }

            const timestamp = Date.now();

            if (idFrontImage) {
                const frontFilename = `${userId}_front_${timestamp}.jpg`;
                const frontPath = path.join(uploadsDir, frontFilename);
                const frontBase64 = idFrontImage.replace(/^data:image\/\w+;base64,/, '');
                fs.writeFileSync(frontPath, Buffer.from(frontBase64, 'base64'));
                updateData.idFrontImageUrl = `/uploads/id-documents/${frontFilename}`;
            }

            if (idBackImage) {
                const backFilename = `${userId}_back_${timestamp}.jpg`;
                const backPath = path.join(uploadsDir, backFilename);
                const backBase64 = idBackImage.replace(/^data:image\/\w+;base64,/, '');
                fs.writeFileSync(backPath, Buffer.from(backBase64, 'base64'));
                updateData.idBackImageUrl = `/uploads/id-documents/${backFilename}`;
            }

            // Set verification status to pending if both images are provided
            if (idFrontImage && idBackImage) {
                updateData.verificationStatus = 'pending';
            }
        }

        const updatedUser = await User.findByIdAndUpdate(
            userId,
            { $set: updateData },
            { new: true }
        );

        if (!updatedUser) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        logEvents(
            `Profile setup completed for user: ${updatedUser.email}`,
            'profileLog.log'
        );

        res.status(200).json({
            success: true,
            message: 'Profile setup completed successfully',
            user: updatedUser.toJSON()
        });

    } catch (error) {
        logEvents(
            `Profile setup error: ${error.message}`,
            'profileErrLog.log'
        );

        res.status(500).json({
            success: false,
            message: error.message || 'Error completing profile setup'
        });
    }
};
