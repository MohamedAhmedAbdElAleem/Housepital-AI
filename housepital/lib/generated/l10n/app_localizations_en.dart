// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Housepital';

  @override
  String get appTagline => 'AI-Powered Home Healthcare';

  @override
  String get loading => 'Loading...';

  @override
  String get settings => 'Settings';

  @override
  String get appearanceLanguage => 'Appearance & Language';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get onboarding1Title => 'Professional Care\nAt Your Doorstep';

  @override
  String get onboarding1Desc =>
      'Get certified nurses and healthcare professionals\ndelivered to your home, on-demand or scheduled';

  @override
  String get onboarding2Title => 'AI-Powered\nHealthcare Assistant';

  @override
  String get onboarding2Desc =>
      'Smart recommendations and 24/7 support with\nour intelligent healthcare companion';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get skipIntro => 'Skip Intro';

  @override
  String get version => 'Version 1.0.0';

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get loginSubtitle => 'Login to your Housepital account';

  @override
  String get emailLabel => 'Email Address';

  @override
  String get emailHint => 'Enter your email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get rememberMe => 'Remember Me';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get loginButton => 'Login';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get registerHere => 'Register Here';

  @override
  String get orLoginWith => 'Or login with';

  @override
  String get google => 'Google';

  @override
  String get apple => 'Apple';

  @override
  String get sessionExpired => 'Session expired. Please login with password.';

  @override
  String get warningEmptyEmail => 'Please enter your email';

  @override
  String get warningInvalidEmail => 'Please enter a valid email';

  @override
  String get warningEmptyPassword => 'Please enter your password';

  @override
  String get errorInvalidCredentials => 'Invalid email or password';

  @override
  String get forgotPasswordTitle => 'Forgot Password?';

  @override
  String get forgotPasswordSubtitle =>
      '🔐 Don\'t worry! We\'ll help you reset it';

  @override
  String get resetViaEmail => 'Reset via Email';

  @override
  String get sendVerificationCodeDesc => 'We\'ll send a verification code';

  @override
  String get emailHintForgot => 'Enter your registered email';

  @override
  String get sendCodeButton => 'Send Verification Code';

  @override
  String get resendCode => 'Resend Code';

  @override
  String get securityTips => 'Security Tips';

  @override
  String get tipSpamFolder =>
      'Check your spam folder if you don\'t see the email';

  @override
  String get tipCodeExpiry => 'Code expires in 10 minutes';

  @override
  String get tipNeverShare => 'Never share your code with anyone';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get otpSentSuccess => 'Verification code sent to your email';

  @override
  String get otpSendFailed => 'Failed to send code';

  @override
  String get noInternet => 'No internet connection';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get createAccountTitle => 'Create Account';

  @override
  String get registerSubtitle => '🏥 Join us for better healthcare';

  @override
  String registrationStep(Object current, Object total) {
    return 'Step $current of $total';
  }

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get fullNameHint => 'Enter your full name';

  @override
  String get mobileLabel => 'Mobile Number';

  @override
  String get mobileHint => '01012345678';

  @override
  String get passwordHintRegister => 'Create a strong password';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Re-enter your password';

  @override
  String get agreeTo => 'I agree to the ';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get and => ' and ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get signIn => 'Sign In';

  @override
  String get passwordTooShort => 'Too Short';

  @override
  String get passwordWeak => 'Weak';

  @override
  String get passwordMedium => 'Medium';

  @override
  String get passwordStrong => 'Strong';

  @override
  String get passwordVeryStrong => 'Very Strong';

  @override
  String get warningEmptyName => 'Please enter your full name';

  @override
  String get warningShortName => 'Name must be at least 3 characters';

  @override
  String get warningEmptyMobile => 'Please enter your mobile number';

  @override
  String get warningInvalidMobile =>
      'Please enter a valid Egyptian mobile number';

  @override
  String get warningEmptyConfirmPassword => 'Please confirm your password';

  @override
  String get warningPasswordMismatch => 'Passwords do not match';

  @override
  String get warningAgreeTerms => 'Please agree to Terms of Service';

  @override
  String get registrationSuccess =>
      'Registration successful! Complete your profile';

  @override
  String get serverError => 'Server error. Please try again';

  @override
  String get verifyEmailTitle => 'Verify Your Email';

  @override
  String get otpVerifySuccess => 'Email verified successfully!';

  @override
  String get tooManyAttempts => 'Too many failed attempts. Request a new code.';

  @override
  String get warningCompleteOtp => 'Please enter the complete 6-digit code';

  @override
  String invalidOtpRemaining(Object remaining) {
    return 'Invalid code. $remaining attempts remaining.';
  }

  @override
  String get accountLocked => 'Account locked! Request a new code.';

  @override
  String get waitBeforeResend => 'Please wait before requesting new code';

  @override
  String get newOtpSent => 'New verification code sent!';

  @override
  String get resendFailed => 'Failed to resend code';

  @override
  String get codeExpiresIn => 'Code expires in';

  @override
  String get enterVerificationCode => 'Enter verification code';

  @override
  String attemptIndicator(Object current, Object total) {
    return 'Attempt $current of $total';
  }

  @override
  String get didntReceiveCode => 'Didn\'t receive the code?';

  @override
  String get resend => 'Resend';

  @override
  String get verifyEmailButton => 'Verify Email';

  @override
  String get locked => 'Locked';

  @override
  String get securityNotice => 'Security Notice';

  @override
  String get securityNoticeDesc =>
      'Never share this code with anyone. Our team will never ask for it.';

  @override
  String get createNewPasswordTitle => 'Create New Password';

  @override
  String get newPasswordSubtitle => '🔒 Make it strong and unique';

  @override
  String get newPasswordLabel => 'New Password';

  @override
  String get passwordRequirements => 'Password Requirements';

  @override
  String get min6Chars => 'At least 6 characters';

  @override
  String get passwordsMatch => 'Passwords match';

  @override
  String get resetPasswordButton => 'Reset Password';

  @override
  String get passwordTips => 'Password Tips';

  @override
  String get tipMixChars => 'Use a mix of letters, numbers & symbols';

  @override
  String get tipAvoidPersonalInfo => 'Avoid using personal information';

  @override
  String get tipDontReuse => 'Don\'t reuse passwords from other sites';

  @override
  String get warningEmptyNewPassword => 'Please enter a new password';

  @override
  String get resetFailed => 'Failed to reset password';

  @override
  String get resetSuccessTitle => 'Password Reset\nSuccessful! 🎉';

  @override
  String get resetSuccessSubtitle =>
      'Your password has been changed successfully.\nYou can now login with your new password.';

  @override
  String get tipPrivatePassword => 'Keep your password private';

  @override
  String get tipChangeRegularly => 'Change it every 3-6 months';

  @override
  String get tipSignOutUnknown => 'Sign out from unknown devices';

  @override
  String get verificationSuccessTitle => 'Verification\nSuccessful! 🎉';

  @override
  String get verificationSuccessSubtitle =>
      'Your identity has been verified successfully';

  @override
  String get identityVerified => 'Identity Verified';

  @override
  String get idConfirmed => 'Your ID has been confirmed';

  @override
  String get documentsApproved => 'Documents Approved';

  @override
  String get documentsValid => 'All documents are valid';

  @override
  String get accountSecured => 'Account Secured';

  @override
  String get accountProtected => 'Your account is protected';

  @override
  String get done => 'Done';

  @override
  String get whatYouCanDo => 'What You Can Do Now';

  @override
  String get bookServices => 'Book medical services';

  @override
  String get requestVisits => 'Request home visits';

  @override
  String get chatProviders => 'Chat with healthcare providers';

  @override
  String get accessHistory => 'Access your medical history';

  @override
  String get continueToLogin => 'Continue to Login';

  @override
  String get medicalHistoryTitle => 'Medical History';

  @override
  String get skip => 'Skip';

  @override
  String get stepInfo => 'Info';

  @override
  String get stepMedical => 'Medical';

  @override
  String get stepId => 'ID';

  @override
  String get healthInfoTitle => 'Health Information';

  @override
  String get healthInfoSubtitle => 'Help us provide better care for you';

  @override
  String get healthInfoSafetyDesc =>
      'This information helps our medical team prepare better for your visits and ensures your safety.';

  @override
  String get bloodTypeTitle => 'Blood Type';

  @override
  String get optionalLabel => '(Optional)';

  @override
  String get chronicDiseasesTitle => 'Chronic Diseases';

  @override
  String get noChronicDiseases => 'I don\'t have any chronic diseases';

  @override
  String get allergiesTitle => 'Allergies';

  @override
  String get noAllergies => 'I don\'t have any known allergies';

  @override
  String get otherConditionsTitle => 'Other Medical Conditions';

  @override
  String get otherConditionsHint => 'Describe any other medical conditions...';

  @override
  String get currentMedicationsTitle => 'Current Medications';

  @override
  String get currentMedicationsHint =>
      'List any medications you are currently taking...';

  @override
  String get saving => 'Saving...';

  @override
  String get continueButton => 'Continue';

  @override
  String get saveMedicalInfoError =>
      'Could not save medical info. You can update it later.';

  @override
  String get diabetes => 'Diabetes';

  @override
  String get highBloodPressure => 'High Blood Pressure';

  @override
  String get heartDisease => 'Heart Disease';

  @override
  String get asthma => 'Asthma';

  @override
  String get kidneyDisease => 'Kidney Disease';

  @override
  String get liverDisease => 'Liver Disease';

  @override
  String get cancer => 'Cancer';

  @override
  String get thyroidDisorder => 'Thyroid Disorder';

  @override
  String get arthritis => 'Arthritis';

  @override
  String get epilepsy => 'Epilepsy';

  @override
  String get penicillin => 'Penicillin';

  @override
  String get sulfaDrugs => 'Sulfa Drugs';

  @override
  String get aspirin => 'Aspirin';

  @override
  String get ibuprofen => 'Ibuprofen';

  @override
  String get latex => 'Latex';

  @override
  String get peanuts => 'Peanuts';

  @override
  String get shellfish => 'Shellfish';

  @override
  String get eggs => 'Eggs';

  @override
  String get verifyIdentityTitle => 'Verify Your Identity';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get verifyIdentityDesc =>
      'As a licensed medical service, we need to verify your identity to ensure safety and trust for everyone.';

  @override
  String get securePrivateTitle => 'Secure & Private';

  @override
  String get securePrivateDesc => 'Your data is encrypted and protected';

  @override
  String get quickProcessTitle => 'Quick Process';

  @override
  String get quickProcessDesc => 'Verification takes less than 2 minutes';

  @override
  String get oneTimeOnlyTitle => 'One-Time Only';

  @override
  String get oneTimeOnlyDesc => 'Verify once, access all services';

  @override
  String get verifyNowButton => 'Verify Now';

  @override
  String get doItLater => 'I\'ll do this later';

  @override
  String get idVerificationTitle => 'Identity Verification';

  @override
  String get scanFrontSide => 'Scan Front Side';

  @override
  String get scanBackSide => 'Scan Back Side';

  @override
  String stepXofY(Object current, Object total) {
    return 'Step $current of $total';
  }

  @override
  String get frontLabel => 'Front';

  @override
  String get backLabel => 'Back';

  @override
  String get positionFrontId => 'Position Front Side of ID';

  @override
  String get positionBackId => 'Position Back Side of ID';

  @override
  String get keepWithinFrame => 'Keep the card within the frame';

  @override
  String get tipsForResults => 'Tips for best results';

  @override
  String get goodLighting => 'Ensure good lighting';

  @override
  String get flatAligned => 'Keep ID flat and aligned';

  @override
  String get avoidBlur => 'Avoid blur and reflections';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get uploadGallery => 'Upload from Gallery';

  @override
  String get processingImage => 'Processing Image...';

  @override
  String get pleaseWait => 'Please wait';

  @override
  String get uploadingDocs => 'Uploading Documents...';

  @override
  String get securelySavingId => 'Securely saving your ID';

  @override
  String get encryptedConnection => 'End-to-end encrypted';

  @override
  String idPreview(Object side) {
    return '$side ID Preview';
  }

  @override
  String get clearReadablePrompt =>
      'Make sure all details are clear and readable';

  @override
  String get retake => 'Retake';

  @override
  String get upload => 'Upload';

  @override
  String get frontSide => 'Front';

  @override
  String get backSide => 'Back';

  @override
  String get cameraError => 'Failed to open camera';

  @override
  String get galleryError => 'Failed to open gallery';

  @override
  String get noImageError => 'No image selected';

  @override
  String get processImageError => 'Failed to process image';

  @override
  String uploadFailed(Object error) {
    return 'Upload failed: $error';
  }

  @override
  String get docsSubmittedTitle => 'Documents Submitted!';

  @override
  String get docsSubmittedDesc =>
      'Your ID has been sent for review.\nOur team will verify it shortly.';

  @override
  String get pendingAdminReview => 'Pending Admin Review';

  @override
  String get takes24to48Hours => 'Usually takes 24-48 hours';

  @override
  String get gotItContinue => 'Got it, Continue';

  @override
  String get reviewNotice => 'You can start using the app while we review';

  @override
  String get navHome => 'Home';

  @override
  String get navBookings => 'Bookings';

  @override
  String get navAI => 'AI Assistant';

  @override
  String get navAlerts => 'Alerts';

  @override
  String get navProfile => 'Profile';

  @override
  String get visitCompletedTitle => 'Visit Completed';

  @override
  String visitCompletedSubtitle(Object nurseName) {
    return 'Care by $nurseName';
  }

  @override
  String get orderSummaryTitle => 'Order Summary';

  @override
  String get serviceLabel => 'Service';

  @override
  String get destinationFeeLabel => 'Destination Fee';

  @override
  String get platformFeeLabel => 'Platform Fee';

  @override
  String get totalLabel => 'Total';

  @override
  String get visitReportTitle => 'Visit Report';

  @override
  String rateNurseTitle(Object nurseName) {
    return 'Rate $nurseName';
  }

  @override
  String get ratingSubmittedTitle => 'Rating Submitted';

  @override
  String get ratingPrompt => 'How was the service provided?';

  @override
  String get ratingThanks => 'Thank you for your feedback!';

  @override
  String get ratingSelectError => 'Please select a rating';

  @override
  String get reviewHint => 'Write a review (optional)...';

  @override
  String get submitRating => 'Submit Rating';

  @override
  String get submitting => 'Submitting...';

  @override
  String get ratingThanksSnack => 'Thank you for rating!';

  @override
  String get ratingSaved => 'Rating saved successfully!';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get currencyEgp => 'EGP';

  @override
  String get defaultNurseName => 'Nurse';
}
