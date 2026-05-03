const SystemSettings = require("../models/SystemSettings");

/**
 * @desc    Get global system settings
 * @route   GET /api/settings
 * @access  Private (Admin)
 */
exports.getSettings = async (req, res) => {
    try {
        const settings = await SystemSettings.getSettings();
        res.status(200).json({
            success: true,
            settings
        });
    } catch (error) {
        console.error("Error fetching settings:", error);
        res.status(500).json({
            success: false,
            message: "Error fetching system settings",
            error: error.message
        });
    }
};

/**
 * @desc    Update system settings
 * @route   PATCH /api/settings
 * @access  Private (Admin)
 */
exports.updateSettings = async (req, res) => {
    try {
        const settings = await SystemSettings.getSettings();
        
        // Update fields if provided
        const { 
            commissionRate, 
            minDestinationFee, 
            maxDestinationFee, 
            payoutSchedule,
            adminNotifications,
            isMaintenanceMode 
        } = req.body;

        if (commissionRate !== undefined) settings.commissionRate = commissionRate;
        if (minDestinationFee !== undefined) settings.minDestinationFee = minDestinationFee;
        if (maxDestinationFee !== undefined) settings.maxDestinationFee = maxDestinationFee;
        if (payoutSchedule !== undefined) settings.payoutSchedule = payoutSchedule;
        if (adminNotifications !== undefined) {
            settings.adminNotifications = {
                ...settings.adminNotifications,
                ...adminNotifications
            };
        }
        if (isMaintenanceMode !== undefined) settings.isMaintenanceMode = isMaintenanceMode;

        settings.lastUpdatedBy = req.user.id;
        await settings.save();

        res.status(200).json({
            success: true,
            message: "Settings updated successfully",
            settings
        });
    } catch (error) {
        console.error("Error updating settings:", error);
        res.status(500).json({
            success: false,
            message: "Error updating system settings",
            error: error.message
        });
    }
};
