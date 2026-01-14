const Service = require("../models/Service");
const Doctor = require("../models/Doctor");

// @desc    Add new service
// @route   POST /api/services
// @access  Private (Doctor only)
const addService = async (req, res) => {
    try {
        const userId = req.user.id;
        
        const doctor = await Doctor.findOne({ user: userId });
        if (!doctor) {
            return res.status(404).json({ message: "Doctor profile not found" });
        }

        const {
            name,
            nameAr,
            description,
            descriptionAr,
            category,
            // providerId comes from doctor._id
            // providerModel is "Doctor"
            clinics,
            price,
            currency,
            durationMinutes,
            requiresTools,
            toolsList,
            estimatedToolsDeposit,
            requiresPrescription
        } = req.body;

        const service = new Service({
            name,
            nameAr,
            description,
            descriptionAr,
            type: "clinic", // Default for doctor services for now, or can be passed
            category: category || "general",
            providerId: doctor._id,
            providerModel: "Doctor",
            clinics: clinics || [],
            price,
            currency: currency || "EGP",
            durationMinutes,
            requiresTools: requiresTools || false,
            toolsList: toolsList || [],
            estimatedToolsDeposit: estimatedToolsDeposit || 0,
            requiresPrescription: requiresPrescription || false
        });

        await service.save();

        res.status(201).json({
            success: true,
            data: service
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Server Error", error: error.message });
    }
};

// @desc    Get all services for current doctor
// @route   GET /api/services/my-services
// @access  Private (Doctor only)
const getMyServices = async (req, res) => {
    try {
        const userId = req.user.id;
        
        const doctor = await Doctor.findOne({ user: userId });
        if (!doctor) {
            return res.status(404).json({ message: "Doctor profile not found" });
        }

        // Find services where providerId matches doctor._id and isActive is true
        const services = await Service.find({ providerId: doctor._id, isActive: true })
                                      .sort({ createdAt: -1 });

        res.json({
            success: true,
            count: services.length,
            data: services
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Server Error" });
    }
};

// @desc    Update service
// @route   PUT /api/services/:id
// @access  Private (Doctor only)
const updateService = async (req, res) => {
    try {
        const userId = req.user.id;
        const serviceId = req.params.id;

        const doctor = await Doctor.findOne({ user: userId });
        if (!doctor) {
            return res.status(404).json({ message: "Doctor profile not found" });
        }

        let service = await Service.findById(serviceId);
        if (!service) {
            return res.status(404).json({ message: "Service not found" });
        }

        // Verify ownership
        if (service.providerId.toString() !== doctor._id.toString()) {
            return res.status(403).json({ message: "Not authorized to update this service" });
        }

        const allowedUpdates = [
            "name", "nameAr", "description", "descriptionAr", "category", 
            "clinics", "price", "durationMinutes", "isActive", "requiresPrescription"
        ];

        allowedUpdates.forEach((field) => {
            if (req.body[field] !== undefined) {
                service[field] = req.body[field];
            }
        });

        await service.save();

        res.json({
            success: true,
            data: service
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Server Error" });
    }
};

// @desc    Delete service (soft delete)
// @route   DELETE /api/services/:id
// @access  Private (Doctor only)
const deleteService = async (req, res) => {
    try {
        const userId = req.user.id;
        const serviceId = req.params.id;

        const doctor = await Doctor.findOne({ user: userId });
        if (!doctor) {
            return res.status(404).json({ message: "Doctor profile not found" });
        }

        let service = await Service.findById(serviceId);
        if (!service) {
            return res.status(404).json({ message: "Service not found" });
        }

        if (service.providerId.toString() !== doctor._id.toString()) {
            return res.status(403).json({ message: "Not authorized to delete this service" });
        }

        // Soft delete
        service.isActive = false;
        await service.save();

        res.json({ success: true, message: "Service deactivated successfully" });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Server Error" });
    }
};

// @desc    Get all active services (Public)
// @route   GET /api/services/public
// @access  Public
const getPublicServices = async (req, res) => {
    try {
        const { category, type, minPrice, maxPrice } = req.query;
        
        let query = { isActive: true };
        
        if (category) {
            query.category = { $regex: category, $options: 'i' };
        }
        if (type) {
            query.type = type;
        }
        if (minPrice) {
            query.price = { ...query.price, $gte: Number(minPrice) };
        }
        if (maxPrice) {
            query.price = { ...query.price, $lte: Number(maxPrice) };
        }

        const services = await Service.find(query)
            .populate({
                path: 'providerId',
                select: 'specialization rating',
                populate: {
                    path: 'user',
                    select: 'name profilePictureUrl'
                }
            })
            .populate('clinics', 'name address')
            .sort({ createdAt: -1 });

        res.json({
            success: true,
            count: services.length,
            data: services
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Server Error" });
    }
};

module.exports = {
    addService,
    getMyServices,
    updateService,
    deleteService,
    getPublicServices
};
