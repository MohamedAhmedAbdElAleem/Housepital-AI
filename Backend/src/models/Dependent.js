const mongoose = require("mongoose");

const dependentSchema = new mongoose.Schema(
{

    responsibleUser: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: [true, "Responsible user id is required"],
      index: true
    },

    fullName: {
        type: String,
        required: [true, "Full name is required"],
        trim: true,
        minlength: 3,
        maxlength: 100
    },

    relationship: {
        type: String,
        required: [true, "Relationship to the user is required"],
        enum: [
            "father", "mother", "son", "daughter",
            "brother", "sister", "grandparent",
            "grandchild", "spouse", "other"
        ]
    },

    dateOfBirth: {
        type: Date,
        required: [true, "Date of birth is required"]
    },

    gender: {
        type: String,
        required: [true, "Gender is required"],
        enum: ["male", "female"]
    },

    mobile: {
        type: String,
        default: null,
        match: [/^01[0125][0-9]{8}$/, "Invalid Egyptian mobile number"],
    },

    chronicConditions: {
        type: [String],
        default: []
    },

    allergies: {
        type: [String],
        default: []
    },

    nationalId: {
        type: String,
        trim: true,
        match: [/^[0-9]{14}$/, "Invalid national ID"]
    },

    birthCertificateId: {
        type: String,
        trim: true,
        match: [/^[0-9]{9,20}$/, "Invalid birth certificate ID"] 
    }
},
{
    timestamps: true
});


dependentSchema.pre("validate", function(next) {
    if (!this.nationalId && !this.birthCertificateId) {
        return next(new Error("Either national ID or birth certificate ID is required"));
    }
    next();
});

module.exports = mongoose.model("Dependent",dependentSchema)