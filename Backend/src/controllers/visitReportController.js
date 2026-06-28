const Booking = require("../models/Booking");
const VisitReport = require("../models/VisitReport");
const Nurse = require("../models/Nurse");
const { sendNotification } = require("../services/notificationService");

// ─── Helper: check if follow-up is emergency ─────────────────────────────────

async function _sendCriticalAlertIfNeeded(visitReport, booking) {
  const isCritical =
    visitReport.hasAbnormalVitals ||
    visitReport.patientStatus.overallCondition === "critical" ||
    visitReport.followUp.urgency === "emergency";

  if (!isCritical || visitReport.criticalAlertSent) return;

  try {
    // Alert the patient
    await sendNotification({
      userId: booking.userId.toString(),
      title: "⚠️ Critical Health Alert",
      body: `Your nurse detected abnormal readings during the visit. Please contact your doctor immediately.`,
      titleAr: "⚠️ تحذير صحي عاجل",
      bodyAr: `اكتشفت ممرضتك قيمًا غير طبيعية خلال الزيارة. يرجى التواصل مع طبيبك فورًا.`,
      type: "critical_alert",
      referenceId: booking._id,
      referenceType: "booking",
      priority: "urgent",
      metadata: {
        urgency: visitReport.followUp.urgency,
        hasAbnormalVitals: visitReport.hasAbnormalVitals,
      },
    });

    visitReport.criticalAlertSent = true;
    await visitReport.save();
    console.log(`🚨 Critical alert sent for booking ${booking._id}`);
  } catch (err) {
    console.error("⚠️ Could not send critical alert:", err.message);
  }
}

// ─── Controllers ─────────────────────────────────────────────────────────────

/**
 * @desc    Submit a structured visit report and complete the visit
 * @route   POST /api/bookings/:id/complete-with-report
 * @access  Private (Nurse)
 */
exports.completeWithReport = async (req, res) => {
  try {
    const { id } = req.params;
    const nurseProfile = await Nurse.findOne({ user: req.user?.id });

    if (!nurseProfile) {
      return res
        .status(404)
        .json({ success: false, message: "Nurse profile not found" });
    }

    const booking = await Booking.findById(id).populate(
      "userId",
      "name email mobile"
    );
    if (!booking) {
      return res
        .status(404)
        .json({ success: false, message: "Booking not found" });
    }

    // Authorization check
    if (booking.assignedNurse?.toString() !== nurseProfile._id.toString()) {
      return res
        .status(403)
        .json({ success: false, message: "Not authorized for this booking" });
    }

    if (booking.status !== "in-progress") {
      console.error(`❌ completeWithReport blocked: booking ${id} has status '${booking.status}' (expected 'in-progress')`);
      return res.status(400).json({
        success: false,
        message: `Visit must be in progress to complete (current status: ${booking.status})`,
      });
    }

    const {
      patientStatus,
      vitals,
      careProvided,
      notes,
      followUp,
      visitDurationMinutes,
    } = req.body;

    // Validate required fields
    if (!patientStatus?.overallCondition || !patientStatus?.consciousnessLevel) {
      return res.status(400).json({
        success: false,
        message: "Patient status (overall condition & consciousness) is required",
      });
    }
    if (patientStatus?.painLevel === undefined || patientStatus?.painLevel === null) {
      return res.status(400).json({
        success: false,
        message: "Pain level is required",
      });
    }
    if (!careProvided?.servicesPerformed?.length) {
      return res.status(400).json({
        success: false,
        message: "At least one service performed must be recorded",
      });
    }

    // Build visit report
    const visitReport = new VisitReport({
      bookingId: booking._id,
      patientId: booking.patientId,
      dependentId: booking.dependentId,
      nurseId: nurseProfile._id,
      patientStatus: patientStatus || {},
      vitals: vitals || {},
      careProvided: careProvided || {},
      notes: notes || {},
      followUp: followUp || {},
      visitDurationMinutes:
        visitDurationMinutes || _calcDurationMinutes(booking.visitStartedAt),
      nurseSignedAt: new Date(),
    });

    await visitReport.save(); // pre-save hook classifies vitals

    // Update booking: mark completed, store report reference
    const walletService = require("../services/walletService");

    booking.status = "completed";
    booking.visitEndedAt = new Date();
    booking.visitReportId = visitReport._id;
    // Keep backward compat: store a short text summary in the legacy field
    booking.visitReport = _buildReportSummary(visitReport);
    booking.paymentStatus = "paid";
    booking.paidAt = new Date();
    await booking.save();

    // Re-fetch with populated userId so the Flutter client gets a properly
    // shaped booking object (userId as { name, email, mobile } not an ObjectId)
    const populatedBooking = await Booking.findById(booking._id).populate(
      "userId",
      "name email mobile"
    );

    // Deduct nurse commission (15%)
    try {
      const nurseUser = await Nurse.findById(nurseProfile._id).select("user");
      const totalAmount = booking.totalAmount || booking.servicePrice || 0;
      if (totalAmount > 0 && nurseUser) {
        const commissionResult = await walletService.deductNurseCommission(
          nurseUser.user.toString(),
          totalAmount,
          booking._id.toString()
        );
        console.log(
          `💰 Nurse commission deducted. New balance: ${commissionResult.newBalance}`
        );
      }
    } catch (commissionError) {
      console.error(
        "⚠️ Commission error (visit still completed):",
        commissionError.message
      );
    }
    // Critical alert if needed — wrapped so it never fails the response
    try {
      await _sendCriticalAlertIfNeeded(visitReport, booking);
    } catch (alertErr) {
      console.error("⚠️ Critical alert error (visit still completed):", alertErr.message);
    }

    // Notify patient — wrapped so a notification failure never fails the response
    try {
      await sendNotification({
        userId: booking.userId.toString(),
        title: "Visit Completed 🎉",
        body: `Your ${booking.serviceName} visit is complete. Tap to view your visit report.`,
        titleAr: "اكتملت الزيارة 🎉",
        bodyAr: `اكتملت زيارة ${booking.serviceName}. اضغط لعرض تقرير الزيارة.`,
        type: "booking_completed",
        referenceId: booking._id,
        referenceType: "booking",
        priority: visitReport.hasAbnormalVitals ? "urgent" : "normal",
        metadata: {
          serviceName: booking.serviceName,
          hasAbnormalVitals: visitReport.hasAbnormalVitals,
          followUpUrgency: visitReport.followUp.urgency,
        },
      });
    } catch (notifErr) {
      console.error("⚠️ Notification error (visit still completed):", notifErr.message);
    }

    console.log(`✅ Visit completed with report for booking ${id}`);

    res.status(200).json({
      success: true,
      message: "Visit completed successfully",
      booking: populatedBooking,
      visitReport: visitReport,
    });
  } catch (error) {
    // Handle duplicate report (unique constraint on bookingId)
    if (error.code === 11000) {
      return res.status(400).json({
        success: false,
        message: "A visit report for this booking already exists",
      });
    }
    console.error("❌ Error completing visit with report:", error);
    res.status(500).json({
      success: false,
      message: "Error completing visit",
      error: error.message,
    });
  }
};

/**
 * @desc    Get visit report for a specific booking
 * @route   GET /api/bookings/:id/visit-report
 * @access  Private (Nurse or Patient who owns booking)
 */
exports.getVisitReport = async (req, res) => {
  try {
    const { id } = req.params;

    const booking = await Booking.findById(id);
    if (!booking) {
      return res
        .status(404)
        .json({ success: false, message: "Booking not found" });
    }

    // Auth: must be the assigned nurse OR the patient
    const userId = req.user?.id;
    const nurseProfile = await Nurse.findOne({ user: userId }).select("_id");
    const isNurse =
      nurseProfile &&
      booking.assignedNurse?.toString() === nurseProfile._id.toString();
    const isPatient = booking.userId.toString() === userId;

    if (!isNurse && !isPatient) {
      return res
        .status(403)
        .json({ success: false, message: "Not authorized" });
    }

    const visitReport = await VisitReport.findOne({
      bookingId: id,
    }).populate("nurseId", "user").populate({
      path: "nurseId",
      populate: { path: "user", select: "name mobile" },
    });

    if (!visitReport) {
      return res.status(404).json({
        success: false,
        message: "Visit report not found for this booking",
      });
    }

    res.status(200).json({ success: true, visitReport });
  } catch (error) {
    console.error("❌ Error fetching visit report:", error);
    res.status(500).json({
      success: false,
      message: "Error fetching visit report",
      error: error.message,
    });
  }
};

/**
 * @desc    Get all visit reports for a patient (history)
 * @route   GET /api/patients/:patientId/visit-reports
 * @access  Private
 */
exports.getPatientVisitReports = async (req, res) => {
  try {
    const { patientId } = req.params;
    const userId = req.user?.id;

    // Check if the user is a nurse or doctor
    const isNurse = await require("../models/Nurse").exists({ user: userId });
    const isDoctor = await require("../models/Doctor").exists({ user: userId });

    // Must be the patient themselves, or a nurse, doctor, or admin
    if (!isNurse && !isDoctor) {
      const user = await require("../models/User").findById(userId);
      if (!user) {
        return res
          .status(401)
          .json({ success: false, message: "Not authenticated" });
      }
    }

    // Support searching either direct patientId or dependentId
    const query = {
      $or: [
        { patientId },
        { dependentId: patientId }
      ]
    };

    const reports = await VisitReport.find(query)
      .sort({ createdAt: -1 })
      .limit(20)
      .populate({
        path: "nurseId",
        select: "user rating",
        populate: { path: "user", select: "name" },
      })
      .populate("bookingId", "serviceName visitStartedAt visitEndedAt");

    res.status(200).json({ success: true, reports });
  } catch (error) {
    console.error("❌ Error fetching patient visit reports:", error);
    res.status(500).json({
      success: false,
      message: "Error fetching visit reports",
      error: error.message,
    });
  }
};

/**
 * @desc    Get the last visit report for a patient (for prefill on next visit)
 * @route   GET /api/patients/:patientId/last-visit-report
 * @access  Private (Nurse/Doctor)
 */
exports.getLastVisitReport = async (req, res) => {
  try {
    const { patientId } = req.params;

    const query = {
      $or: [
        { patientId },
        { dependentId: patientId }
      ]
    };

    const lastReport = await VisitReport.findOne(query)
      .sort({ createdAt: -1 })
      .select("patientStatus vitals careProvided createdAt bookingId")
      .populate("bookingId", "serviceName visitStartedAt");

    res.status(200).json({
      success: true,
      lastReport: lastReport || null,
    });
  } catch (error) {
    console.error("❌ Error fetching last visit report:", error);
    res.status(500).json({
      success: false,
      message: "Error fetching last visit report",
      error: error.message,
    });
  }
};

// ─── Private helpers ──────────────────────────────────────────────────────────

function _calcDurationMinutes(visitStartedAt) {
  if (!visitStartedAt) return 0;
  return Math.round((Date.now() - new Date(visitStartedAt).getTime()) / 60000);
}

function _buildReportSummary(visitReport) {
  const cond = visitReport.patientStatus.overallCondition;
  const pain = visitReport.patientStatus.painLevel;
  const services = visitReport.careProvided.servicesPerformed.join(", ");
  const obs = visitReport.notes.clinicalObservations || "";
  const followUp = visitReport.followUp.required
    ? `Follow-up: ${visitReport.followUp.urgency}`
    : "No follow-up required";
  return `Condition: ${cond} | Pain: ${pain}/10 | Services: ${services}${obs ? " | " + obs.substring(0, 100) : ""} | ${followUp}`;
}
