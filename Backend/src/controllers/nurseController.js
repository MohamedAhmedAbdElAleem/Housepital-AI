const Nurse = require('../models/Nurse');
const User = require('../models/User');
const { logEvents } = require('../middleware/logger');

/**
 * @desc    Get nurse profile
 * @route   GET /api/nurse/profile
 * @access  Private (Nurse only)
 */
exports.getNurseProfile = async (req, res) => {
    try {
        const userId = req.user.id;

        const nurse = await Nurse.findOne({ user: userId }).populate('user', 'name email mobile');

        if (!nurse) {
            return res.status(404).json({
                success: false,
                message: 'Nurse profile not found'
            });
        }

        res.status(200).json({
            success: true,
            nurse
        });
    } catch (error) {
        logEvents(`Get nurse profile error: ${error.message}`, 'nurseErrLog.log');
        res.status(500).json({
            success: false,
            message: error.message || 'Error fetching nurse profile'
        });
    }
};

/**
 * @desc    Create or update nurse profile
 * @route   POST /api/nurse/profile
 * @access  Private (Nurse only)
 */
exports.updateNurseProfile = async (req, res) => {
    try {
        const userId = req.user.id;
        const {
            licenseNumber,
            specialization,
            yearsOfExperience,
            skills,
            bio,
            gender,
            nationalIdUrl,
            degreeUrl,
            licenseUrl,
            bankAccount,
            eWallet
        } = req.body;

        console.log('📝 Updating nurse profile for user:', userId);

        // Find existing nurse profile or create new one
        let nurse = await Nurse.findOne({ user: userId });

        if (!nurse) {
            // Create new nurse profile
            nurse = new Nurse({
                user: userId,
                licenseNumber,
                specialization,
                yearsOfExperience: yearsOfExperience || 0,
                skills: skills || [],
                bio,
                gender,
                nationalIdUrl,
                degreeUrl,
                licenseUrl,
                bankAccount,
                eWallet,
                profileStatus: 'incomplete'
            });
        } else {
            // Update existing profile
            if (licenseNumber) nurse.licenseNumber = licenseNumber;
            if (specialization) nurse.specialization = specialization;
            if (yearsOfExperience !== undefined) nurse.yearsOfExperience = yearsOfExperience;
            if (skills) nurse.skills = skills;
            if (bio) nurse.bio = bio;
            if (gender) nurse.gender = gender;
            if (nationalIdUrl) nurse.nationalIdUrl = nationalIdUrl;
            if (degreeUrl) nurse.degreeUrl = degreeUrl;
            if (licenseUrl) nurse.licenseUrl = licenseUrl;
            if (bankAccount) nurse.bankAccount = bankAccount;
            if (eWallet) nurse.eWallet = eWallet;
            
            if (typeof req.body.isOnline !== 'undefined') {
                const wentOnline = req.body.isOnline === true && nurse.isOnline === false;
                nurse.isOnline = req.body.isOnline;
                
                // If the nurse just went online via API, trigger the matching recheck
                if (wentOnline) {
                    const { recheckSearchingRequests } = require('../services/matchingService');
                    const io = req.app.get("io");
                    if (io) {
                        recheckSearchingRequests(io);
                    }
                }
            }
        }

        // Check if profile is complete
        const isProfileComplete = nurse.licenseNumber &&
            nurse.specialization &&
            nurse.yearsOfExperience !== undefined &&
            nurse.gender &&
            nurse.nationalIdUrl &&
            nurse.degreeUrl &&
            nurse.licenseUrl &&
            (nurse.bankAccount?.accountNumber || nurse.eWallet?.number);

        if (isProfileComplete && nurse.profileStatus === 'incomplete') {
            nurse.profileStatus = 'pending_review';
            nurse.verificationStatus = 'pending';
            console.log('✅ Profile is complete, status changed to pending_review');
        }

        await nurse.save();

        logEvents(`Nurse profile updated: ${userId}`, 'nurseLog.log');

        res.status(200).json({
            success: true,
            message: 'Profile updated successfully',
            nurse
        });
    } catch (error) {
        logEvents(`Update nurse profile error: ${error.message}`, 'nurseErrLog.log');
        res.status(500).json({
            success: false,
            message: error.message || 'Error updating nurse profile'
        });
    }
};

/**
 * @desc    Submit profile for review
 * @route   POST /api/nurse/profile/submit
 * @access  Private (Nurse only)
 */
exports.submitProfileForReview = async (req, res) => {
    try {
        const userId = req.user.id;

        const nurse = await Nurse.findOne({ user: userId });

        if (!nurse) {
            return res.status(404).json({
                success: false,
                message: 'Nurse profile not found'
            });
        }

        // Validate all required fields are present
        const requiredFields = {
            licenseNumber: nurse.licenseNumber,
            specialization: nurse.specialization,
            yearsOfExperience: nurse.yearsOfExperience !== undefined,
            gender: nurse.gender,
            nationalIdUrl: nurse.nationalIdUrl,
            degreeUrl: nurse.degreeUrl,
            licenseUrl: nurse.licenseUrl,
            payoutMethod: nurse.bankAccount?.accountNumber || nurse.eWallet?.number
        };

        const missingFields = Object.keys(requiredFields).filter(key => !requiredFields[key]);

        if (missingFields.length > 0) {
            return res.status(400).json({
                success: false,
                message: 'Profile is incomplete',
                missingFields
            });
        }

        nurse.profileStatus = 'pending_review';
        await nurse.save();

        logEvents(`Nurse profile submitted for review: ${userId}`, 'nurseLog.log');

        res.status(200).json({
            success: true,
            message: 'Profile submitted for review successfully',
            nurse
        });
    } catch (error) {
        logEvents(`Submit profile error: ${error.message}`, 'nurseErrLog.log');
        res.status(500).json({
            success: false,
            message: error.message || 'Error submitting profile'
        });
    }
};

/**
 * @desc    Get profile completion status
 * @route   GET /api/nurse/profile/status
 * @access  Private (Nurse only)
 */
exports.getProfileStatus = async (req, res) => {
    try {
        const userId = req.user.id;

        const nurse = await Nurse.findOne({ user: userId });

        if (!nurse) {
            return res.status(200).json({
                success: true,
                profileStatus: 'incomplete',
                profileExists: false,
                completionPercentage: 0
            });
        }

        // Calculate completion percentage
        const requiredFields = [
            'licenseNumber',
            'specialization',
            'yearsOfExperience',
            'gender',
            'nationalIdUrl',
            'degreeUrl',
            'licenseUrl',
            'bio'
        ];

        const completedFields = requiredFields.filter(field => {
            if (field === 'yearsOfExperience') {
                return nurse[field] !== undefined && nurse[field] !== null;
            }
            return nurse[field];
        });

        const hasPayoutMethod = nurse.bankAccount?.accountNumber || nurse.eWallet?.number;
        const totalRequired = requiredFields.length + 1; // +1 for payout method
        const totalCompleted = completedFields.length + (hasPayoutMethod ? 1 : 0);
        const completionPercentage = Math.round((totalCompleted / totalRequired) * 100);

        res.status(200).json({
            success: true,
            profileStatus: nurse.profileStatus,
            profileExists: true,
            completionPercentage,
            verificationStatus: nurse.verificationStatus,
            rejectionReason: nurse.rejectionReason
        });
    } catch (error) {
        logEvents(`Get profile status error: ${error.message}`, 'nurseErrLog.log');
        res.status(500).json({
            success: false,
            message: error.message || 'Error fetching profile status'
        });
    }
};

/**
 * @desc    Get all pending nurses (for admin review)
 * @route   GET /api/nurse/pending
 * @access  Private (Admin only)
 */
exports.getPendingNurses = async (req, res) => {
    try {
        if (req.user.role !== 'admin') {
            return res.status(403).json({ message: "Admin access only" });
        }

        const status = req.query.status || 'pending';
        const filter = {};
        if (status !== 'all') {
            filter.verificationStatus = status;
        }

        const nurses = await Nurse.find(filter)
            .populate("user", "name email mobile profilePictureUrl createdAt")
            .sort({ createdAt: -1 });

        res.json({
            success: true,
            count: nurses.length,
            data: nurses
        });
    } catch (error) {
        logEvents(`Get pending nurses error: ${error.message}`, 'nurseErrLog.log');
        res.status(500).json({ message: "Server Error" });
    }
};

/**
 * @desc    Approve or reject a nurse
 * @route   PUT /api/nurse/:nurseId/verify
 * @access  Private (Admin only)
 */
exports.verifyNurse = async (req, res) => {
    try {
        if (req.user.role !== 'admin') {
            return res.status(403).json({ message: "Admin access only" });
        }

        const { nurseId } = req.params;
        const { action, rejectionReason } = req.body;

        if (!['approve', 'reject'].includes(action)) {
            return res.status(400).json({ message: "Action must be 'approve' or 'reject'" });
        }

        const nurse = await Nurse.findById(nurseId).populate("user", "name email");
        if (!nurse) {
            return res.status(404).json({ message: "Nurse not found" });
        }

        if (action === 'approve') {
            nurse.verificationStatus = 'approved';
            nurse.profileStatus = 'approved';
            nurse.rejectionReason = null;
            nurse.verifiedBy = req.user.id;
            nurse.verifiedAt = new Date();
            await nurse.save();

            res.json({
                success: true,
                message: `Nurse ${nurse.user?.name || 'Unknown'} has been approved.`,
                data: nurse
            });
        } else {
            if (!rejectionReason || rejectionReason.trim() === '') {
                return res.status(400).json({ message: "Rejection reason is required" });
            }

            nurse.verificationStatus = 'rejected';
            nurse.profileStatus = 'rejected';
            nurse.rejectionReason = rejectionReason;
            nurse.verifiedBy = req.user.id;
            nurse.verifiedAt = new Date();
            await nurse.save();

            res.json({
                success: true,
                message: `Nurse ${nurse.user?.name || 'Unknown'} has been rejected.`,
                data: nurse
            });
        }
    } catch (error) {
        logEvents(`Verify nurse error: ${error.message}`, 'nurseErrLog.log');
        res.status(500).json({ message: "Server Error", error: error.message });
    }
};
