const User = require('../models/User');
const { logEvents } = require('../middleware/logger');
const cloudinaryService = require('../services/cloudinaryService');

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
 * @desc    Upload ID document (front or back) to Cloudinary
 * @route   POST /api/profile/upload-id
 * @access  Private
 * @body    { side: 'front'|'back', imageBase64?: string, imageUrl?: string, publicId?: string }
 */
exports.uploadIdDocument = async (req, res) => {
    try {
        const userId = req.user.id;
        const { side, imageBase64, imageUrl, publicId: providedPublicId } = req.body;

        // Validate side
        if (!side || !['front', 'back'].includes(side)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid side. Must be "front" or "back"'
            });
        }

        let finalUrl, finalPublicId;

        // If imageUrl is provided, use it directly (already uploaded to Cloudinary)
        if (imageUrl) {
            finalUrl = imageUrl;
            finalPublicId = providedPublicId || cloudinaryService.extractPublicId(imageUrl);
        } 
        // Otherwise, upload base64 to Cloudinary
        else if (imageBase64) {
            const uploadResult = await cloudinaryService.uploadFromBase64(imageBase64, {
                folder: cloudinaryService.FOLDERS.ID_DOCUMENTS,
                publicId: `${userId}_${side}_${Date.now()}`,
            });

            if (!uploadResult.success) {
                return res.status(500).json({
                    success: false,
                    message: uploadResult.error || 'Failed to upload image'
                });
            }

            finalUrl = uploadResult.url;
            finalPublicId = uploadResult.publicId;
        } else {
            return res.status(400).json({
                success: false,
                message: 'Either imageUrl or imageBase64 is required'
            });
        }

        // Update user's ID document URL
        const updateField = side === 'front' ? 'idFrontImageUrl' : 'idBackImageUrl';
        const publicIdField = side === 'front' ? 'idFrontPublicId' : 'idBackPublicId';
        
        const updateData = {
            [updateField]: finalUrl,
            [publicIdField]: finalPublicId
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
            // Delete uploaded image if user update fails
            if (finalPublicId) {
                await cloudinaryService.deleteImage(finalPublicId);
            }
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        // Log the upload
        logEvents(
            `ID ${side} uploaded to Cloudinary for user: ${updatedUser.email}`,
            'profileLog.log'
        );

        res.status(200).json({
            success: true,
            message: `ID ${side} uploaded successfully`,
            imageUrl: finalUrl,
            publicId: finalPublicId,
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

        // Handle ID images if provided - upload to Cloudinary
        if (idFrontImage || idBackImage) {
            const timestamp = Date.now();

            if (idFrontImage) {
                const frontResult = await cloudinaryService.uploadFromBase64(idFrontImage, {
                    folder: cloudinaryService.FOLDERS.ID_DOCUMENTS,
                    publicId: `${userId}_front_${timestamp}`,
                });
                if (frontResult.success) {
                    updateData.idFrontImageUrl = frontResult.url;
                    updateData.idFrontPublicId = frontResult.publicId;
                }
            }

            if (idBackImage) {
                const backResult = await cloudinaryService.uploadFromBase64(idBackImage, {
                    folder: cloudinaryService.FOLDERS.ID_DOCUMENTS,
                    publicId: `${userId}_back_${timestamp}`,
                });
                if (backResult.success) {
                    updateData.idBackImageUrl = backResult.url;
                    updateData.idBackPublicId = backResult.publicId;
                }
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
