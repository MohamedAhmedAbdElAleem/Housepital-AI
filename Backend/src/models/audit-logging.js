const mongoose = require("mongoose");

const auditLogSchema = new mongoose.Schema({
  action: { type: String, required: true }, // 'REGISTER', 'APPROVE', 'REJECT'
  performedBy: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true }, // admin or system
  targetUser: {
    id: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    name: String,
    email: String,
    mobile: String,
    role: String
  },
  status: { type: String }, // 'PENDING', 'APPROVED', 'REJECTED'
  description: { type: String },
  timestamp: { type: Date, default: Date.now }
});

module.exports = mongoose.model("AuditLog", auditLogSchema);
