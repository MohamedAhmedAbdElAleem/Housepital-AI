const User = require("../models/User");
const nodemailer = require("nodemailer");
const bcrypt = require("bcrypt");

// Function to generate HTML email template
const generateOTPEmailHTML = (otp, userName = '') => {
  return `
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <style>
        * {
          margin: 0;
          padding: 0;
          box-sizing: border-box;
        }
        body {
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
          background-color: #f5f7fa;
          padding: 20px;
        }
        .email-container {
          max-width: 600px;
          margin: 0 auto;
          background: white;
          border-radius: 16px;
          overflow: hidden;
          box-shadow: 0 4px 20px rgba(0,0,0,0.08);
        }
        .header {
          background: linear-gradient(135deg, #2ECC71 0%, #27AE60 100%);
          padding: 50px 20px;
          text-align: center;
        }
        .header h1 {
          color: white;
          font-size: 28px;
          font-weight: 700;
          margin: 0;
        }
        .header p {
          color: rgba(255,255,255,0.9);
          font-size: 16px;
          margin-top: 8px;
        }
        .content {
          padding: 40px 30px;
        }
        .greeting {
          font-size: 18px;
          color: #2c3e50;
          margin-bottom: 20px;
          font-weight: 600;
        }
        .message {
          color: #5a6c7d;
          font-size: 15px;
          line-height: 1.6;
          margin-bottom: 30px;
        }
        .otp-container {
          background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
          border-radius: 12px;
          padding: 30px;
          text-align: center;
          margin: 30px 0;
          border: 2px dashed #2ECC71;
        }
        .otp-label {
          font-size: 14px;
          color: #6c757d;
          text-transform: uppercase;
          letter-spacing: 1px;
          margin-bottom: 12px;
          font-weight: 600;
        }
        .otp-code {
          font-size: 48px;
          font-weight: bold;
          color: #2ECC71;
          letter-spacing: 12px;
          font-family: 'Courier New', monospace;
          text-shadow: 0 2px 4px rgba(46,204,113,0.2);
        }
        .info-box {
          background: #fff3cd;
          border-left: 4px solid #ffc107;
          padding: 16px 20px;
          margin: 25px 0;
          border-radius: 8px;
        }
        .info-box-title {
          color: #856404;
          font-weight: 600;
          font-size: 14px;
          margin-bottom: 8px;
          display: flex;
          align-items: center;
        }
        .info-box-title::before {
          content: "⚠️";
          margin-right: 8px;
          font-size: 18px;
        }
        .info-box ul {
          list-style: none;
          padding: 0;
          margin: 0;
        }
        .info-box li {
          color: #856404;
          font-size: 13px;
          line-height: 1.8;
          padding-left: 20px;
          position: relative;
        }
        .info-box li::before {
          content: "•";
          position: absolute;
          left: 8px;
          font-weight: bold;
        }
        .security-note {
          background: #e7f3ff;
          border-left: 4px solid #0066cc;
          padding: 16px 20px;
          margin: 25px 0;
          border-radius: 8px;
          color: #004085;
          font-size: 13px;
          line-height: 1.6;
        }
        .footer {
          background: #f8f9fa;
          padding: 30px 20px;
          text-align: center;
          border-top: 1px solid #dee2e6;
        }
        .footer-logo {
          font-size: 24px;
          font-weight: bold;
          color: #2ECC71;
          margin-bottom: 12px;
        }
        .footer-text {
          color: #6c757d;
          font-size: 13px;
          line-height: 1.6;
        }
        .footer-links {
          margin-top: 15px;
        }
        .footer-links a {
          color: #2ECC71;
          text-decoration: none;
          margin: 0 10px;
          font-size: 12px;
        }
        .footer-links a:hover {
          text-decoration: underline;
        }
      </style>
    </head>
    <body>
      <div class="email-container">
        <div class="header">
          <h1>Email Verification</h1>
          <p>Secure your Housepital account</p>
        </div>
        
        <div class="content">
          <div class="greeting">Hello${userName ? ' ' + userName : ''},</div>
          
          <div class="message">
            Thank you for registering with <strong>Housepital</strong> - your trusted AI-powered home nursing platform. To complete your registration and secure your account, please verify your email address using the code below.
          </div>
          
          <div class="otp-container">
            <div class="otp-label">Your Verification Code</div>
            <div class="otp-code">${otp}</div>
          </div>
          
          <div class="info-box">
            <div class="info-box-title">Important Information</div>
            <ul>
              <li>This code is valid for <strong>10 minutes only</strong></li>
              <li>You have <strong>5 attempts</strong> to enter the correct code</li>
              <li>Never share this code with anyone</li>
            </ul>
          </div>
          
          <div class="security-note">
            🔒 <strong>Security Tip:</strong> If you didn't request this verification code, please ignore this email and ensure your account is secure. For any concerns, contact our support team immediately.
          </div>
        </div>
        
        <div class="footer">
          <div class="footer-logo">Housepital</div>
          <div class="footer-text">
            AI-Powered Home Nursing Services<br>
            Bringing professional healthcare to your doorstep<br>
            © 2025 Housepital. All rights reserved.
          </div>
          <div class="footer-links">
            <a href="#">Privacy Policy</a> |
            <a href="#">Terms of Service</a> |
            <a href="#">Contact Support</a>
          </div>
        </div>
      </div>
    </body>
    </html>
  `;
};

// ========== Request OTP ==========
const requestOTP = async (req, res) => {
  const { contact, contactType, purpose } = req.body;

  try {
    // Validate input
    if (!contact || !contactType || !purpose) {
      return res.status(400).json({
        success: false,
        message: "Missing required fields",
        errors: [
          {
            field: "contact",
            message: "contact, contactType, and purpose are required"
          }
        ]
      });
    }

    // Find user by email or phone
    let user;
    if (contactType === "email") {
      user = await User.findOne({ email: contact });
    } else if (contactType === "phone") {
      user = await User.findOne({ mobile: contact });
    } else {
      return res.status(400).json({
        success: false,
        message: "Invalid contactType",
        errors: [
          {
            field: "contactType",
            message: "contactType must be 'email' or 'phone'"
          }
        ]
      });
    }

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
        errors: [
          {
            field: "contact",
            message: "No account found with this email/phone"
          }
        ]
      });
    }

    // Generate 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const otpId = `otp_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

    // Store OTP with 10-minute expiration
    user.resetOTP = otp;
    user.otpExpires = Date.now() + 10 * 60 * 1000; // 10 minutes
    user.otpAttempts = 0;
    await user.save();

    // Send OTP via email or SMS
    if (contactType === "email") {
      const transporter = nodemailer.createTransport({
        service: "gmail",
        auth: {
          user: process.env.EMAIL_USER,
          pass: process.env.EMAIL_PASS,
        },
      });

      const htmlContent = generateOTPEmailHTML(otp, user.firstName);

      await transporter.sendMail({
        from: `"Housepital - AI Home Nursing" <${process.env.EMAIL_USER}>`,
        to: contact,
        subject: "🏥 Verify Your Email - Housepital",
        html: htmlContent,
        text: `Your verification code is: ${otp}\nValid for 10 minutes only.\n\nIf you didn't request this, please ignore this email.`,
      });
    }
    // TODO: Add SMS service for phone OTP

    res.status(200).json({
      success: true,
      message: "OTP sent successfully",
      data: {
        contact: contactType === "email" ? contact : "***",
        contactType: contactType,
        otpId: otpId,
        expiresIn: 600,
        attempt: 1,
        maxAttempts: 5
      }
    });
  } catch (err) {
    console.error("OTP Request Error:", err);
    res.status(500).json({
      success: false,
      message: "Failed to send OTP",
      error: err.message
    });
  }
};

// ========== Verify OTP ==========
const verifyOTP = async (req, res) => {
  const { otpId, code, contact } = req.body;

  try {
    // Validate input
    if (!code || !contact) {
      return res.status(400).json({
        success: false,
        message: "Missing required fields",
        errors: [
          {
            field: "code",
            message: "code and contact are required"
          }
        ]
      });
    }

    // Validate OTP format
    if (!/^\d{6}$/.test(code)) {
      return res.status(400).json({
        success: false,
        message: "Invalid OTP format",
        errors: [
          {
            field: "code",
            message: "OTP must be 6 digits"
          }
        ]
      });
    }

    // Find user
    let user = await User.findOne({ email: contact }).select("+resetOTP +otpExpires +otpAttempts");

    if (!user) {
      user = await User.findOne({ mobile: contact }).select("+resetOTP +otpExpires +otpAttempts");
    }

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
        errors: [
          {
            field: "contact",
            message: "No account found with this email/phone"
          }
        ]
      });
    }

    // Check if OTP exists
    if (!user.resetOTP) {
      return res.status(400).json({
        success: false,
        message: "OTP not found",
        errors: [
          {
            field: "otpId",
            message: "Please request a new OTP"
          }
        ]
      });
    }

    // Check if OTP expired
    if (Date.now() > user.otpExpires) {
      user.resetOTP = undefined;
      user.otpExpires = undefined;
      user.otpAttempts = 0;
      await user.save();

      return res.status(400).json({
        success: false,
        message: "OTP expired",
        errors: [
          {
            field: "code",
            message: "OTP has expired. Please request a new one."
          }
        ]
      });
    }

    // Check attempts
    if (user.otpAttempts >= 5) {
      user.resetOTP = undefined;
      user.otpExpires = undefined;
      user.otpAttempts = 0;
      await user.save();

      return res.status(429).json({
        success: false,
        message: "Too many verification attempts",
        data: {
          attempt: user.otpAttempts,
          maxAttempts: 5,
          retryAfter: 900
        }
      });
    }

    // Check if OTP matches
    if (user.resetOTP !== code) {
      user.otpAttempts += 1;
      await user.save();

      return res.status(400).json({
        success: false,
        message: "Invalid OTP",
        errors: [
          {
            field: "code",
            message: "OTP code is incorrect"
          }
        ],
        data: {
          attempt: user.otpAttempts,
          maxAttempts: 5
        }
      });
    }

    // OTP verified successfully
    const verificationToken = `token_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

    user.resetOTP = undefined;
    user.otpExpires = undefined;
    user.otpAttempts = 0;
    await user.save();

    res.status(200).json({
      success: true,
      message: "OTP verified successfully",
      data: {
        verified: true,
        verificationToken: verificationToken,
        expiresIn: 3600,
        tokenType: "Bearer"
      }
    });
  } catch (err) {
    console.error("OTP Verification Error:", err);
    res.status(500).json({
      success: false,
      message: "Verification failed",
      error: err.message
    });
  }
};

// ========== Resend OTP ==========
const resendOTP = async (req, res) => {
  const { otpId, contact } = req.body;

  try {
    if (!contact) {
      return res.status(400).json({
        success: false,
        message: "Missing contact information",
        errors: [
          {
            field: "contact",
            message: "contact is required"
          }
        ]
      });
    }

    // Find user
    let user = await User.findOne({ email: contact }).select("+resetOTP +otpExpires +otpAttempts");
    let contactType = "email";

    if (!user) {
      user = await User.findOne({ mobile: contact }).select("+resetOTP +otpExpires +otpAttempts");
      contactType = "phone";
    }

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found"
      });
    }

    // Check if max resends reached
    const resendCount = user.resetOTP ? 1 : 0; // Simplified - in production track resends properly
    if (resendCount >= 3) {
      return res.status(400).json({
        success: false,
        message: "Cannot resend OTP",
        errors: [
          {
            field: "otpId",
            message: "Maximum resend attempts exceeded"
          }
        ]
      });
    }

    // Generate new OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    user.resetOTP = otp;
    user.otpExpires = Date.now() + 10 * 60 * 1000;
    user.otpAttempts = 0;
    await user.save();

    // Send OTP (email only for now)
    if (contactType === "email") {
      const transporter = nodemailer.createTransport({
        service: "gmail",
        auth: {
          user: process.env.EMAIL_USER,
          pass: process.env.EMAIL_PASS,
        },
      });

      const htmlContent = generateOTPEmailHTML(otp, user.firstName);

      await transporter.sendMail({
        from: `"Housepital - AI Home Nursing" <${process.env.EMAIL_USER}>`,
        to: contact,
        subject: "🏥 Verify Your Email - Housepital",
        html: htmlContent,
        text: `Your verification code is: ${otp}\nValid for 10 minutes only.\n\nIf you didn't request this, please ignore this email.`,
      });
    }

    res.status(200).json({
      success: true,
      message: "OTP resent successfully",
      data: {
        contact: contactType === "email" ? contact : "***",
        otpId: otpId,
        expiresIn: 600,
        resendCount: resendCount + 1,
        maxResends: 3
      }
    });
  } catch (err) {
    console.error("OTP Resend Error:", err);
    res.status(500).json({
      success: false,
      message: "Failed to resend OTP",
      error: err.message
    });
  }
};

// ========== Reset Password ==========
const resetPassword = async (req, res) => {
  const { email, newPassword, confirmPassword } = req.body;

  try {
    if (!email || !newPassword || !confirmPassword) {
      return res.status(400).json({
        success: false,
        message: "Missing required fields"
      });
    }

    if (newPassword !== confirmPassword) {
      return res.status(400).json({
        success: false,
        message: "Passwords do not match",
        errors: [
          {
            field: "confirmPassword",
            message: "Passwords must match"
          }
        ]
      });
    }

    // Simple password validation - minimum 6 characters
    if (newPassword.length < 6) {
      return res.status(400).json({
        success: false,
        message: "Password too short",
        errors: [
          {
            field: "newPassword",
            message: "Password must be at least 6 characters"
          }
        ]
      });
    }

    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found"
      });
    }

    // Update password
    user.password_hash = newPassword;
    user.resetOTP = undefined;
    user.otpExpires = undefined;
    user.otpAttempts = 0;
    await user.save();
    console.log(`✅ Password updated for user: ${email.toLowerCase()}`);

    // Try to clear Redis cache (optional - don't fail if Redis is down)
    try {
      const { createRedisClient } = require('../caching/redis');
      const redis = createRedisClient();
      await redis.del(email.toLowerCase());
      console.log(`🗑️ Cleared Redis cache for user: ${email.toLowerCase()}`);
    } catch (redisErr) {
      console.log(`⚠️ Redis cache clear failed (optional): ${redisErr.message}`);
    }

    res.status(200).json({
      success: true,
      message: "Password reset successfully",
      data: {
        email: email
      }
    });
  } catch (err) {
    console.error("Password Reset Error:", err);
    res.status(500).json({
      success: false,
      message: "Failed to reset password",
      error: err.message
    });
  }
};

module.exports = { requestOTP, verifyOTP, resendOTP, resetPassword };
