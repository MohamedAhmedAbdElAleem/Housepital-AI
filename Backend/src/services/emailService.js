/**
 * Email Service for Housepital
 * Uses nodemailer with Gmail to send emails.
 */

const nodemailer = require("nodemailer");

const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
    },
});

/**
 * Send a doctor verification approval email.
 * @param {string} toEmail
 * @param {string} doctorName
 */
async function sendApprovalEmail(toEmail, doctorName) {
    const mailOptions = {
        from: `"Housepital" <${process.env.EMAIL_USER}>`,
        to: toEmail,
        subject: "Your Housepital Doctor Account Has Been Approved! ✅",
        html: `
            <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
                <div style="background: linear-gradient(135deg, #2664EC, #3498BB); padding: 30px; border-radius: 12px 12px 0 0; text-align: center;">
                    <h1 style="color: white; margin: 0;">Welcome to Housepital!</h1>
                </div>
                <div style="background: #f8fafc; padding: 30px; border-radius: 0 0 12px 12px; border: 1px solid #e2e8f0;">
                    <h2 style="color: #1e293b;">Congratulations, Dr. ${doctorName}!</h2>
                    <p style="color: #475569; font-size: 16px; line-height: 1.6;">
                        Your account has been reviewed and <strong style="color: #16a34a;">approved</strong> by our team.
                    </p>
                    <p style="color: #475569; font-size: 16px; line-height: 1.6;">
                        You can now log in to the Housepital Staff app, set up your clinics and services, 
                        and start receiving patient bookings.
                    </p>
                    <div style="background: #eff6ff; border-left: 4px solid #2664EC; padding: 16px; border-radius: 4px; margin: 20px 0;">
                        <p style="color: #1e40af; margin: 0; font-size: 14px;">
                            <strong>Next Steps:</strong><br>
                            1. Open the Housepital Staff app and log in<br>
                            2. Set up your clinics and working hours<br>
                            3. Add your services and pricing<br>
                            4. Toggle your status to "Active" to start receiving bookings
                        </p>
                    </div>
                    <p style="color: #94a3b8; font-size: 12px; margin-top: 30px;">
                        — The Housepital Team
                    </p>
                </div>
            </div>
        `,
    };

    try {
        await transporter.sendMail(mailOptions);
        console.log(`✅ Approval email sent to ${toEmail}`);
    } catch (error) {
        console.error(`❌ Failed to send approval email to ${toEmail}:`, error.message);
    }
}

/**
 * Send a doctor verification rejection email.
 * @param {string} toEmail
 * @param {string} doctorName
 * @param {string} reason - Rejection reason
 */
async function sendRejectionEmail(toEmail, doctorName, reason) {
    const mailOptions = {
        from: `"Housepital" <${process.env.EMAIL_USER}>`,
        to: toEmail,
        subject: "Housepital Doctor Account — Action Required ⚠️",
        html: `
            <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
                <div style="background: linear-gradient(135deg, #dc2626, #ef4444); padding: 30px; border-radius: 12px 12px 0 0; text-align: center;">
                    <h1 style="color: white; margin: 0;">Application Update</h1>
                </div>
                <div style="background: #f8fafc; padding: 30px; border-radius: 0 0 12px 12px; border: 1px solid #e2e8f0;">
                    <h2 style="color: #1e293b;">Dear Dr. ${doctorName},</h2>
                    <p style="color: #475569; font-size: 16px; line-height: 1.6;">
                        We have reviewed your application and unfortunately it could not be approved at this time.
                    </p>
                    <div style="background: #fef2f2; border-left: 4px solid #dc2626; padding: 16px; border-radius: 4px; margin: 20px 0;">
                        <p style="color: #991b1b; margin: 0; font-size: 14px;">
                            <strong>Rejection Reason:</strong><br>
                            ${reason}
                        </p>
                    </div>
                    <p style="color: #475569; font-size: 16px; line-height: 1.6;">
                        Please update your profile and documents in the Housepital Staff app and re-submit your application.
                        Once updated, your application will be reviewed again.
                    </p>
                    <p style="color: #94a3b8; font-size: 12px; margin-top: 30px;">
                        — The Housepital Team
                    </p>
                </div>
            </div>
        `,
    };

    try {
        await transporter.sendMail(mailOptions);
        console.log(`✅ Rejection email sent to ${toEmail}`);
    } catch (error) {
        console.error(`❌ Failed to send rejection email to ${toEmail}:`, error.message);
    }
}

module.exports = {
    sendApprovalEmail,
    sendRejectionEmail,
};
