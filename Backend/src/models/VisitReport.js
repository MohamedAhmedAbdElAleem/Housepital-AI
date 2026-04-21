const mongoose = require("mongoose");

// ─── Vital Classification Helpers ────────────────────────────────────────────

/**
 * Returns 'normal' | 'high' | 'low' | 'critical' for each vital type.
 * Used server-side to auto-classify on save.
 */
function classifyBP(systolic, diastolic) {
  if (!systolic || !diastolic) return "normal";
  if (systolic < 70 || systolic > 180 || diastolic > 120) return "critical";
  if (systolic < 90 || diastolic < 60) return "low";
  if (systolic > 140 || diastolic > 90) return "high";
  return "normal";
}

function classifyHeartRate(hr) {
  if (!hr) return "normal";
  if (hr < 40 || hr > 150) return "critical";
  if (hr < 60) return "low";
  if (hr > 100) return "high";
  return "normal";
}

function classifyTemperature(temp) {
  if (!temp) return "normal";
  if (temp < 35 || temp > 39.5) return "critical";
  if (temp < 36.1) return "low";
  if (temp > 37.5) return "high";
  return "normal";
}

function classifySpO2(spo2) {
  if (!spo2) return "normal";
  if (spo2 < 90) return "critical";
  if (spo2 < 95) return "low";
  return "normal";
}

// ─── Schema ──────────────────────────────────────────────────────────────────

const visitReportSchema = new mongoose.Schema(
  {
    // ── Links ────────────────────────────────────────────────────────────────
    bookingId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Booking",
      required: true,
      unique: true, // one report per visit
    },
    patientId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    dependentId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Dependent",
    },
    nurseId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Nurse",
      required: true,
    },

    // ── Section A: Patient Status ─────────────────────────────────────────
    patientStatus: {
      overallCondition: {
        type: String,
        enum: ["excellent", "stable", "fair", "poor", "critical"],
        required: true,
      },
      consciousnessLevel: {
        type: String,
        enum: ["alert", "confused", "lethargic", "unresponsive"],
        required: true,
      },
      painLevel: {
        type: Number,
        min: 0,
        max: 10,
        required: true,
      },
      mobility: {
        type: [String],
        enum: ["independent", "needs_help", "bedridden"],
        default: [],
      },
      woundSiteCondition: {
        type: String,
        enum: ["clean", "redness", "swelling", "discharge", "na"],
        default: "na",
      },
    },

    // ── Section B: Vitals ─────────────────────────────────────────────────
    vitals: {
      bloodPressure: {
        systolic: { type: Number },
        diastolic: { type: Number },
        status: {
          type: String,
          enum: ["normal", "high", "low", "critical"],
          default: "normal",
        },
      },
      heartRate: {
        value: { type: Number },
        status: {
          type: String,
          enum: ["normal", "high", "low", "critical"],
          default: "normal",
        },
      },
      temperature: {
        value: { type: Number },
        status: {
          type: String,
          enum: ["normal", "high", "low", "critical"],
          default: "normal",
        },
      },
      oxygenSaturation: {
        value: { type: Number },
        status: {
          type: String,
          enum: ["normal", "low", "critical"],
          default: "normal",
        },
      },
      respiratoryRate: { type: Number }, // optional
      bloodSugar: { type: Number }, // optional
      weight: { type: Number }, // optional
      measuredAt: { type: Date, default: Date.now },
    },

    // Auto-computed flags
    hasAbnormalVitals: { type: Boolean, default: false },
    criticalAlertSent: { type: Boolean, default: false },

    // ── Section C: Care Provided ──────────────────────────────────────────
    careProvided: {
      servicesPerformed: {
        type: [String],
        required: true,
        validate: {
          validator: (arr) => arr.length > 0,
          message: "At least one service must be recorded",
        },
      },
      medications: [
        {
          name: { type: String, trim: true },
          dose: { type: String, trim: true },
          route: {
            type: String,
            enum: ["oral", "iv", "im", "sc", "topical", "other"],
          },
        },
      ],
      procedures: { type: [String], default: [] },
      patientCooperation: {
        type: String,
        enum: ["cooperative", "resistant", "unable"],
        default: "cooperative",
      },
    },

    // ── Section D: Notes & Observations ──────────────────────────────────
    notes: {
      clinicalObservations: {
        type: String,
        maxlength: 500,
        trim: true,
        default: "",
      },
      familyPresent: { type: Boolean, default: false },
      homeEnvironment: {
        type: [String],
        enum: ["clean", "cluttered", "safe", "unsafe"],
        default: [],
      },
      patientFamilyConcerns: {
        type: String,
        maxlength: 250,
        trim: true,
        default: "",
      },
    },

    // ── Section E: Follow-up & Alerts ────────────────────────────────────
    followUp: {
      required: { type: Boolean, default: false },
      urgency: {
        type: String,
        enum: ["routine", "within_48h", "urgent", "emergency"],
        default: "routine",
      },
      recommendedActions: {
        type: [String],
        enum: [
          "doctor_consult",
          "lab_tests",
          "medication_review",
          "physio",
          "hospital_admission",
          "family_education",
          "other",
        ],
        default: [],
      },
      alertMessage: { type: String, maxlength: 200, trim: true, default: "" },
    },

    // ── Meta ──────────────────────────────────────────────────────────────
    visitDurationMinutes: { type: Number },
    nurseSignedAt: { type: Date },
    reportPdfUrl: { type: String },
    reportVersion: { type: Number, default: 1 },
  },
  { timestamps: true }
);

// ─── Pre-save: auto-classify vitals ──────────────────────────────────────────

visitReportSchema.pre("save", function (next) {
  const v = this.vitals;

  if (v.bloodPressure?.systolic && v.bloodPressure?.diastolic) {
    v.bloodPressure.status = classifyBP(
      v.bloodPressure.systolic,
      v.bloodPressure.diastolic
    );
  }
  if (v.heartRate?.value) {
    v.heartRate.status = classifyHeartRate(v.heartRate.value);
  }
  if (v.temperature?.value) {
    v.temperature.status = classifyTemperature(v.temperature.value);
  }
  if (v.oxygenSaturation?.value) {
    v.oxygenSaturation.status = classifySpO2(v.oxygenSaturation.value);
  }

  // Flag if any vital is abnormal
  const statuses = [
    v.bloodPressure?.status,
    v.heartRate?.status,
    v.temperature?.status,
    v.oxygenSaturation?.status,
  ];
  this.hasAbnormalVitals = statuses.some((s) => s && s !== "normal");

  next();
});

// ─── Indexes ─────────────────────────────────────────────────────────────────

visitReportSchema.index({ patientId: 1, createdAt: -1 });
visitReportSchema.index({ nurseId: 1, createdAt: -1 });
visitReportSchema.index({ hasAbnormalVitals: 1, createdAt: -1 });
visitReportSchema.index({ "followUp.urgency": 1, createdAt: -1 });

// ─── Export helpers (for controllers) ────────────────────────────────────────

visitReportSchema.statics.classifyBP = classifyBP;
visitReportSchema.statics.classifyHeartRate = classifyHeartRate;
visitReportSchema.statics.classifyTemperature = classifyTemperature;
visitReportSchema.statics.classifySpO2 = classifySpO2;

module.exports = mongoose.model("VisitReport", visitReportSchema);
