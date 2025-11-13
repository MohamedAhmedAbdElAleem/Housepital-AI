const User = require("../models/User");
const nodemailer = require("nodemailer");
const bcrypt = require("bcrypt");

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

      const htmlContent = `
        <!DOCTYPE html>
        <html dir="rtl" lang="ar">
        <head>
          <meta charset="UTF-8">
          <style>
            body {
              font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
              background-color: #f5f5f5;
              margin: 0;
              padding: 0;
            }
            .container {
              max-width: 600px;
              margin: 40px auto;
              background: white;
              border-radius: 16px;
              overflow: hidden;
              box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            }
            .header {
              background: linear-gradient(135deg, #00b558 0%, #3cd278 100%);
              padding: 40px 20px;
              text-align: center;
            }
            .header h1 {
              color: white;
              margin: 0;
              font-size: 28px;
              font-weight: bold;
            }
            .content {
              padding: 40px 30px;
              text-align: center;
            }
            .otp-box {
              background: #f8f9fa;
              border: 3px dashed #00b558;
              border-radius: 12px;
              padding: 30px;
              margin: 30px 0;
            }
            .otp-code {
              font-size: 48px;
              font-weight: bold;
              color: #00b558;
              letter-spacing: 8px;
              font-family: 'Courier New', monospace;
            }
            .info {
              color: #666;
              font-size: 14px;
              line-height: 1.8;
              margin: 20px 0;
            }
            .warning {
              background: #fff3cd;
              border-right: 4px solid #ffc107;
              padding: 15px;
              margin: 20px 0;
              border-radius: 8px;
            }
            .warning strong {
              color: #856404;
            }
            .footer {
              background: #f8f9fa;
              padding: 20px;
              text-align: center;
              color: #999;
              font-size: 12px;
            }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>🏥 استعادة كلمة المرور</h1>
            </div>
            <div class="content">
              <p class="info">مرحباً،</p>
              <p class="info">لقد تلقينا طلباً لإعادة تعيين كلمة المرور الخاصة بحسابك في نظام Housepital.</p>
              <p class="info">استخدم رمز التحقق التالي لإكمال العملية:</p>
              
              <div class="otp-box">
                <div class="otp-code">${otp}</div>
              </div>
              
              <div class="warning">
                <strong>⚠️ تنبيه:</strong><br>
                • رمز التحقق صالح لمدة <strong>10 دقائق فقط</strong><br>
                • لديك <strong>5 محاولات</strong> لإدخال الرمز الصحيح<br>
                • يمكنك إعادة إرسال الرمز <strong>3 مرات كحد أقصى</strong>
              </div>
              
              <p class="info" style="margin-top: 30px; color: #999;">
                إذا لم تطلب إعادة تعيين كلمة المرور، يرجى تجاهل هذه الرسالة.
              </p>
            </div>
            <div class="footer">
              <p>© 2025 Housepital System. جميع الحقوق محفوظة.</p>
            </div>
          </div>
        </body>
        </html>
      `;

      await transporter.sendMail({
        from: `"Housepital System" <${process.env.EMAIL_USER}>`,
        to: contact,
        subject: "🏥 رمز التحقق - Housepital",
        html: htmlContent,
        text: `رمز التحقق الخاص بك هو: ${otp}\nصالح لمدة 10 دقائق فقط.`,
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

      const htmlContent = `
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <style>
            body { font-family: Arial, sans-serif; }
            .container { max-width: 600px; margin: 20px auto; padding: 20px; background: #f5f5f5; border-radius: 8px; }
            .otp-code { font-size: 36px; font-weight: bold; color: #00b558; letter-spacing: 5px; font-family: monospace; }
          </style>
        </head>
        <body>
          <div class="container">
            <h2>🔐 Your Verification Code</h2>
            <p>Your OTP code is:</p>
            <div class="otp-code">${otp}</div>
            <p>This code expires in 10 minutes.</p>
          </div>
        </body>
        </html>
      `;

      await transporter.sendMail({
        from: `"Housepital System" <${process.env.EMAIL_USER}>`,
        to: contact,
        subject: "🔐 Your Verification Code - Housepital",
        html: htmlContent,
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

    // Validate password strength
    const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;
    if (!passwordRegex.test(newPassword)) {
      return res.status(400).json({
        success: false,
        message: "Password does not meet requirements",
        errors: [
          {
            field: "newPassword",
            message: "Password must be 8+ chars with uppercase, lowercase, digit, and special char"
          }
        ]
      });
    }

    const user = await User.findOne({ email });
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
