require('dotenv').config();
const nodemailer = require('nodemailer');

// Create transporter
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
    }
});

/**
 * Send verification status email to user
 * @param {string} email - User's email address
 * @param {string} name - User's name
 * @param {string} status - 'approved' or 'rejected'
 * @returns {Promise<{success: boolean, message: string}>}
 */
async function sendVerificationEmail(email, name, status) {
    try {
        const isApproved = status === 'approved';
        
        const subject = isApproved 
            ? '✅ Your Housepital Account Has Been Verified!' 
            : '❌ Housepital Account Verification Update';
        
        const htmlContent = isApproved 
            ? `
                <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
                    <div style="background: linear-gradient(135deg, #00C853 0%, #69F0AE 100%); padding: 30px; border-radius: 10px 10px 0 0; text-align: center;">
                        <h1 style="color: white; margin: 0;">🎉 Congratulations!</h1>
                    </div>
                    <div style="background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px;">
                        <p style="font-size: 18px; color: #333;">Dear <strong>${name}</strong>,</p>
                        <p style="font-size: 16px; color: #555; line-height: 1.6;">
                            Great news! Your Housepital account has been <strong style="color: #00C853;">verified successfully</strong>.
                        </p>
                        <p style="font-size: 16px; color: #555; line-height: 1.6;">
                            You now have full access to all our healthcare services. You can:
                        </p>
                        <ul style="font-size: 15px; color: #555; line-height: 1.8;">
                            <li>Book nursing visits</li>
                            <li>Access medical consultations</li>
                            <li>Manage your health records</li>
                            <li>And much more!</li>
                        </ul>
                        <div style="text-align: center; margin-top: 30px;">
                            <a href="#" style="background: #00C853; color: white; padding: 15px 30px; text-decoration: none; border-radius: 25px; font-weight: bold;">Open Housepital App</a>
                        </div>
                        <p style="font-size: 14px; color: #888; margin-top: 30px; text-align: center;">
                            Thank you for choosing Housepital!
                        </p>
                    </div>
                </div>
            `
            : `
                <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
                    <div style="background: linear-gradient(135deg, #EF4444 0%, #F87171 100%); padding: 30px; border-radius: 10px 10px 0 0; text-align: center;">
                        <h1 style="color: white; margin: 0;">Verification Update</h1>
                    </div>
                    <div style="background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px;">
                        <p style="font-size: 18px; color: #333;">Dear <strong>${name}</strong>,</p>
                        <p style="font-size: 16px; color: #555; line-height: 1.6;">
                            We regret to inform you that your Housepital account verification was <strong style="color: #EF4444;">not approved</strong>.
                        </p>
                        <p style="font-size: 16px; color: #555; line-height: 1.6;">
                            This may be due to:
                        </p>
                        <ul style="font-size: 15px; color: #555; line-height: 1.8;">
                            <li>Unclear or unreadable ID documents</li>
                            <li>Information mismatch</li>
                            <li>Incomplete documentation</li>
                        </ul>
                        <p style="font-size: 16px; color: #555; line-height: 1.6;">
                            Please re-upload clear photos of your ID documents and try again.
                        </p>
                        <div style="text-align: center; margin-top: 30px;">
                            <a href="#" style="background: #3B82F6; color: white; padding: 15px 30px; text-decoration: none; border-radius: 25px; font-weight: bold;">Resubmit Documents</a>
                        </div>
                        <p style="font-size: 14px; color: #888; margin-top: 30px; text-align: center;">
                            If you believe this was an error, please contact our support team.
                        </p>
                    </div>
                </div>
            `;

        const mailOptions = {
            from: `"Housepital" <${process.env.EMAIL_USER}>`,
            to: email,
            subject: subject,
            html: htmlContent
        };

        await transporter.sendMail(mailOptions);
        
        return {
            success: true,
            message: 'Email sent successfully'
        };
    } catch (error) {
        console.error('Email sending error:', error);
        return {
            success: false,
            message: error.message || 'Failed to send email'
        };
    }
}

/**
 * Verify email configuration
 */
async function verifyEmailConfig() {
    try {
        await transporter.verify();
        console.log('✉️ Email service configured successfully');
        return true;
    } catch (error) {
        console.error('❌ Email service configuration error:', error.message);
        return false;
    }
}

module.exports = {
    sendVerificationEmail,
    verifyEmailConfig
};
