const mongoose = require("mongoose");

const ratingSchema = new mongoose.Schema(
    {
        // Related Booking
        bookingId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Booking",
            required: [true, "Booking ID is required"],
            index: true
        },
        // Who gave the rating
        raterUserId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: [true, "Rater user ID is required"]
        },
        raterRole: {
            type: String,
            enum: ["customer", "nurse", "doctor"],
            required: true
        },
        // Who received the rating
        ratedUserId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: [true, "Rated user ID is required"]
        },
        ratedRole: {
            type: String,
            enum: ["customer", "nurse", "doctor"],
            required: true
        },
        // Rating Details
        overallRating: {
            type: Number,
            required: [true, "Overall rating is required"],
            min: 1,
            max: 5
        },
        // Specific ratings (optional detailed breakdown)
        punctuality: {
            type: Number,
            min: 1,
            max: 5
        },
        professionalism: {
            type: Number,
            min: 1,
            max: 5
        },
        communication: {
            type: Number,
            min: 1,
            max: 5
        },
        serviceQuality: {
            type: Number,
            min: 1,
            max: 5
        },
        // Review
        review: {
            type: String,
            trim: true,
            maxlength: [500, "Review cannot exceed 500 characters"]
        },
        // Tags (quick feedback options)
        tags: [{
            type: String,
            enum: [
                "friendly", "professional", "punctual", "skilled",
                "patient", "clean", "recommended", "rude", "late",
                "unprofessional", "poor_communication"
            ]
        }],
        // Visibility
        isPublic: {
            type: Boolean,
            default: true
        },
        // Moderation
        isReported: {
            type: Boolean,
            default: false
        },
        reportReason: {
            type: String,
            trim: true
        },
        isHidden: {
            type: Boolean,
            default: false
        },
        hiddenBy: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User"
        },
        hiddenReason: {
            type: String,
            trim: true
        }
    },
    { timestamps: true }
);

// Indexes
ratingSchema.index({ ratedUserId: 1, ratedRole: 1, createdAt: -1 });
ratingSchema.index({ raterUserId: 1, createdAt: -1 });
ratingSchema.index({ bookingId: 1, raterRole: 1 }, { unique: true }); // One rating per role per booking

// Static method to calculate average rating for a user
ratingSchema.statics.calculateAverageRating = async function(userId) {
    const result = await this.aggregate([
        { $match: { ratedUserId: userId, isHidden: false } },
        {
            $group: {
                _id: null,
                avgRating: { $avg: "$overallRating" },
                totalRatings: { $sum: 1 }
            }
        }
    ]);
    
    return result.length > 0 
        ? { avgRating: Math.round(result[0].avgRating * 10) / 10, totalRatings: result[0].totalRatings }
        : { avgRating: 0, totalRatings: 0 };
};

module.exports = mongoose.model("Rating", ratingSchema);
