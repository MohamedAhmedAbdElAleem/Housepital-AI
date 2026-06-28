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

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get welcomeBack => 'Welcome';

  @override
  String get searchPlaceholder => 'What do you need help with?';

  @override
  String get searchSemanticLabel =>
      'Search for clinics, nurses, or use AI Chatbot';

  @override
  String get nursingService => 'Nursing Service';

  @override
  String get assigningNurse => 'Assigning...';

  @override
  String get activeStatus => 'Active';

  @override
  String get housepitalWallet => 'Housepital Wallet';

  @override
  String get availableBalance => 'Available Balance';

  @override
  String get topUp => 'Top Up';

  @override
  String get history => 'History';

  @override
  String get bookNurse => 'Book Nurse';

  @override
  String get homeCare => 'Home care';

  @override
  String get findClinic => 'Find Clinic';

  @override
  String get bookVisits => 'Book visits';

  @override
  String get aiHealthAssistant => 'AI Health Assistant';

  @override
  String get newLabel => 'NEW';

  @override
  String get aiAdviceSubtitle => 'Get instant health advice';

  @override
  String get newsAndOffers => 'News & Offers';

  @override
  String get offer1Title => '20% off General Checkups';

  @override
  String get offer1Subtitle => 'Valid until end of month';

  @override
  String get offer2Title => 'Free Dietitian Consult';

  @override
  String get offer2Subtitle => 'With premium subscription';

  @override
  String get offer3Title => 'Winter Flu Shots Available';

  @override
  String get offer3Subtitle => 'Book home visit now';

  @override
  String offerDetailsSnack(Object title) {
    return 'Offer: $title - Details coming soon';
  }

  @override
  String get dependents => 'Family & Dependents';

  @override
  String get dependentsDesc => 'Manage profiles for your family members';

  @override
  String get securitySection => 'Security';

  @override
  String get biometricLogin => 'Biometric Login';

  @override
  String get biometricLoginDesc =>
      'Use fingerprint or face recognition to unlock';

  @override
  String get biometricNotSupported => 'Biometrics not supported on this device';

  @override
  String get twoFactorAuth => 'Two-Factor Authentication';

  @override
  String get twoFactorAuthDesc =>
      'Secure your account with an extra verification step';

  @override
  String get loginActivity => 'Login Activity';

  @override
  String get loginActivityDesc => 'Monitor active sessions and devices';

  @override
  String get notificationsSection => 'Notifications';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get pushNotificationsDesc =>
      'Receive real-time updates and alerts on your device';

  @override
  String get emailNotifications => 'Email Notifications';

  @override
  String get emailNotificationsDesc =>
      'Get summaries and receipts sent to your inbox';

  @override
  String get smsUpdates => 'SMS Updates';

  @override
  String get smsUpdatesDesc => 'Receive appointment updates via text message';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get dataSection => 'Data & Privacy';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get clearCacheDesc => 'Free up storage space by clearing cached files';

  @override
  String get clearCacheConfirm =>
      'Are you sure you want to clear the app cache? This will free up space but keep your personal settings.';

  @override
  String get cancel => 'Cancel';

  @override
  String get cacheCleared => 'Cache cleared successfully';

  @override
  String get clear => 'Clear';

  @override
  String get clearAiHistory => 'Clear AI History';

  @override
  String get clearAiHistoryDesc =>
      'Permanently delete your AI chatbot conversations';

  @override
  String get clearAiHistoryConfirm =>
      'Are you sure you want to clear your conversation history with the AI Health Assistant? This action cannot be undone.';

  @override
  String get aiHistoryCleared => 'AI history cleared successfully';

  @override
  String get downloadMyData => 'Download My Data';

  @override
  String get downloadMyDataDesc => 'Request a copy of your personal data';

  @override
  String get about => 'About';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get userLabel => 'Patient';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signOutConfirmTitle => 'Sign Out';

  @override
  String get signOutConfirmDesc =>
      'Are you sure you want to sign out of your account?';

  @override
  String get accountSection => 'Account';

  @override
  String get biometricConfirmIdentity =>
      'Please authenticate to confirm identity';

  @override
  String get biometricDisabled => 'Biometric login disabled';

  @override
  String get biometricEnabledSuccess => 'Biometric login enabled successfully!';

  @override
  String get biometricLoginRequired =>
      'Biometric authentication is required to enable this feature';

  @override
  String get myWallet => 'My Wallet';

  @override
  String get myWalletDesc => 'Manage payments, cards, and transaction history';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get personalInfoDesc => 'View and edit your personal profile details';

  @override
  String get filterAll => 'All';

  @override
  String get filterNursing => 'Nursing';

  @override
  String get filterClinic => 'Clinic';

  @override
  String get bookingsTitle => 'My Bookings';

  @override
  String get bookingsSubtitle => 'Track and manage your appointments';

  @override
  String get tabActive => 'Active';

  @override
  String get tabHistory => 'History';

  @override
  String get familyTitle => 'My Family';

  @override
  String get addMember => 'Add Member';

  @override
  String get addFamilyMember => 'Add Family Member';

  @override
  String get aboutFamilyTitle => 'About Family Members';

  @override
  String get aboutFamilyDesc =>
      'Add family members to easily book nursing services for them. You can store their medical information for faster booking.';

  @override
  String get gotIt => 'Got it!';

  @override
  String get loadingFamily => 'Loading family members...';

  @override
  String get noFamilyMembers => 'No Family Members Yet';

  @override
  String get noFamilyMembersDesc =>
      'Add your loved ones to easily book nursing services for them';

  @override
  String get errLoadFamily =>
      'Unable to load family members. Please log in again.';

  @override
  String get years => 'years';

  @override
  String get memberSingle => '1 member';

  @override
  String membersPlural(Object count) {
    return '$count members';
  }

  @override
  String get editFamilyMember => 'Edit Family Member';

  @override
  String get deleteMember => 'Delete Member';

  @override
  String deleteMemberConfirm(Object name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String get actionUndone => 'This action cannot be undone';

  @override
  String get discardChangesTitle => 'Discard Changes?';

  @override
  String get discardChangesDesc =>
      'You have unsaved changes. Are you sure you want to leave without saving?';

  @override
  String get keepEditing => 'Keep Editing';

  @override
  String get discard => 'Discard';

  @override
  String get changesSaved => 'Changes Saved!';

  @override
  String get familyMemberUpdated =>
      'Family member information has been updated successfully.';

  @override
  String get relationship => 'Relationship';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get nationalId => 'National ID';

  @override
  String get birthCertificateId => 'Birth Certificate ID';

  @override
  String get chronicConditions => 'Chronic Conditions';

  @override
  String get allergies => 'Allergies';

  @override
  String get addChronicCondition => 'Add Chronic Disease';

  @override
  String get addAllergy => 'Add Allergy';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get relationshipFather => 'Father';

  @override
  String get relationshipMother => 'Mother';

  @override
  String get relationshipSon => 'Son';

  @override
  String get relationshipDaughter => 'Daughter';

  @override
  String get relationshipBrother => 'Brother';

  @override
  String get relationshipSister => 'Sister';

  @override
  String get relationshipGrandparent => 'Grandparent';

  @override
  String get relationshipGrandchild => 'Grandchild';

  @override
  String get relationshipSpouse => 'Spouse';

  @override
  String get relationshipOther => 'Other';

  @override
  String get savedAddressesTitle => 'Saved Addresses';

  @override
  String get addressSavedSingle => '1 Address Saved';

  @override
  String addressesSavedPlural(Object count) {
    return '$count Addresses Saved';
  }

  @override
  String get manageLocations => 'Manage your delivery locations';

  @override
  String get loadingAddresses => 'Loading addresses...';

  @override
  String get noSavedAddresses => 'No Saved Addresses';

  @override
  String get noSavedAddressesDesc =>
      'Add your first address to get started with home nursing services';

  @override
  String get addFirstAddress => 'Add Your First Address';

  @override
  String get addAddress => 'Add Address';

  @override
  String get aboutAddresses => 'About Addresses';

  @override
  String get addressTypeHome => 'Home';

  @override
  String get addressTypeWork => 'Work';

  @override
  String get addressTypeOther => 'Other';

  @override
  String get addressTypeHomeDesc => 'Your primary residence';

  @override
  String get addressTypeWorkDesc => 'Your workplace address';

  @override
  String get addressTypeOtherDesc => 'Any other location';

  @override
  String get defaultAddressNote => 'Set a default address for faster booking';

  @override
  String get defaultTag => 'DEFAULT';

  @override
  String get addressOptions => 'Address Options';

  @override
  String get setAsDefault => 'Set as Default';

  @override
  String get editAddress => 'Edit Address';

  @override
  String get deleteAddress => 'Delete Address';

  @override
  String get confirmDeleteAddress =>
      'Are you sure you want to delete this address?';

  @override
  String get delete => 'Delete';

  @override
  String get addressDeleted => 'Address deleted successfully';

  @override
  String get addressSetDefault => 'Address set as default successfully';

  @override
  String get errSetDefault => 'Failed to set default address';

  @override
  String get errDeleteAddress => 'Failed to delete address';

  @override
  String get errLoadAddresses =>
      'Unable to load addresses. Please log in again.';

  @override
  String get mapLocation => 'Map Location';

  @override
  String get locationNotSelected => 'Location not selected';

  @override
  String get locationSelected => 'Location selected';

  @override
  String get requiredForTracking => 'Required for nurse tracking';

  @override
  String get pick => 'Pick';

  @override
  String get change => 'Change';

  @override
  String get addressDetails => 'Address Details';

  @override
  String get labelOptional => 'Label (Optional)';

  @override
  String get labelHint => 'e.g., Home, Office, Mom\'s Place';

  @override
  String get streetAddress => 'Street Address';

  @override
  String get enterStreet => 'Enter street address';

  @override
  String get areaDistrict => 'Area / District';

  @override
  String get enterArea => 'Enter area or district';

  @override
  String get city => 'City';

  @override
  String get enterCity => 'Enter city';

  @override
  String get state => 'State';

  @override
  String get enterState => 'Enter state';

  @override
  String get zipCode => 'Zip / Postal Code';

  @override
  String get enterZip => 'Enter zip code';

  @override
  String get preferences => 'Preferences';

  @override
  String get setDefaultAddress => 'Set as default address';

  @override
  String get setDefaultAddressDesc =>
      'Use this address by default for bookings';

  @override
  String get updateAddress => 'Update Address';

  @override
  String get addressUpdated => 'Address Updated!';

  @override
  String get addressUpdatedDesc =>
      'Your address has been updated successfully.';

  @override
  String get pinLocationFirst => 'Please pin your location on the map first.';

  @override
  String get errLoadUserId => 'User ID not found. Please log in again.';

  @override
  String get errUpdateAddress => 'Failed to update address';

  @override
  String get requiredField => 'Required';

  @override
  String get warningUndone => 'This action cannot be undone';

  @override
  String get viewDetails => 'View Details';

  @override
  String get basicInformation => 'Basic Information';

  @override
  String get fullName => 'Full Name';

  @override
  String get mobileNumberOptional => 'Mobile Number (Optional)';

  @override
  String get identification => 'Identification';

  @override
  String get provideOneId => 'Provide at least one ID';

  @override
  String get medicalInformation => 'Medical Information';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get deleteFamilyMemberDesc =>
      'Permanently delete this family member from your account. This action cannot be undone.';

  @override
  String get noChanges => 'No Changes';

  @override
  String noItemsAdded(Object title) {
    return 'No $title added';
  }

  @override
  String get addChronicDiseaseHint => 'e.g., Diabetes, Hypertension';

  @override
  String get addAllergyHint => 'e.g., Penicillin, Peanuts';

  @override
  String get selectRelationshipWarn => 'Please select a relationship';

  @override
  String get selectDobWarn => 'Please select date of birth';

  @override
  String get provideIdWarn =>
      'Please provide either National ID or Birth Certificate ID';

  @override
  String get deleteMemberSuccess => 'Family member deleted successfully';

  @override
  String get selectDate => 'Select date';

  @override
  String get add => 'Add';

  @override
  String get modified => 'Modified';

  @override
  String get deleteFamilyMember => 'Delete Family Member';

  @override
  String get addressType => 'Address Type';

  @override
  String get loadingBookings => 'Loading bookings...';

  @override
  String get noActiveBookings => 'No Active Bookings';

  @override
  String get noActiveBookingsDesc =>
      'Your upcoming appointments will appear here';

  @override
  String get noBookingHistory => 'No Booking History';

  @override
  String get noBookingHistoryDesc => 'Your completed bookings will appear here';

  @override
  String get bookService => 'Book a Service';

  @override
  String get inProgress => 'In Progress';

  @override
  String get inClinic => 'In Clinic';

  @override
  String get nurseArrived => 'Nurse Arrived';

  @override
  String get readyForVisit => 'Ready For Visit';

  @override
  String get onTheWay => 'On The Way';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get awaitingConfirmation => 'Awaiting Confirmation';

  @override
  String get findingNurse => 'Finding Nurse';

  @override
  String get nurseOffersReady => 'Nurse Offers Ready';

  @override
  String get statusPending => 'Pending';

  @override
  String get viewTicket => 'View Ticket';

  @override
  String get track => 'Track';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusNoShow => 'No Show';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get rebook => 'Rebook';

  @override
  String get nurseLabel => 'Nurse';

  @override
  String get cancelBookingTitle => 'Cancel Booking?';

  @override
  String cancelBookingLateDesc(Object fee) {
    return 'Since the nurse is already assigned, a late cancellation fee of $fee EGP will apply.';
  }

  @override
  String get cancelBookingNormalDesc =>
      'Are you sure you want to cancel this booking? This action cannot be undone.';

  @override
  String lateCancellationFee(Object fee) {
    return 'Late Cancellation Fee: $fee EGP';
  }

  @override
  String get goBack => 'Go Back';

  @override
  String get cancelAndPayFee => 'Cancel & Pay Fee';

  @override
  String get yesCancel => 'Yes, Cancel';

  @override
  String get bookingCancelled => 'Booking cancelled';

  @override
  String get matchingRequestCancelled => 'Matching request cancelled';

  @override
  String get failedToCancelMatching => 'Failed to cancel matching request';

  @override
  String get queueLabel => 'Queue';

  @override
  String get digitalTicket => 'Digital Ticket';

  @override
  String get scanAtReception => 'Scan at reception';

  @override
  String get checkInPin => 'Check-in PIN';

  @override
  String get patientLabel => 'Patient';

  @override
  String get clinicLabel => 'Clinic';

  @override
  String get addressLabel => 'Address';

  @override
  String get doctorLabel => 'Doctor';

  @override
  String get timeLabel => 'Time';

  @override
  String get ticketInstruction =>
      'Show this QR code or PIN at the clinic reception to check in.';

  @override
  String get close => 'Close';

  @override
  String get estArrival => 'Est. arrival';

  @override
  String get distance => 'Distance';

  @override
  String get youLabel => 'You';

  @override
  String get visitStartCode => 'VISIT START CODE';

  @override
  String get provideStartCodeDesc =>
      'Provide this to the nurse to begin the session.';

  @override
  String get serviceInProgress => 'Service in Progress';

  @override
  String serviceInProgressDesc(Object serviceName) {
    return 'The nurse is providing $serviceName. The visit will be marked complete soon.';
  }

  @override
  String get newTag => 'New';

  @override
  String get registeredNurse => 'Registered Nurse';

  @override
  String callingNurse(Object phone) {
    return 'Calling $phone...';
  }

  @override
  String get callingEmergency => 'Calling Emergency Services...';

  @override
  String get sosLabel => 'SOS';

  @override
  String get filingReport => 'Filing a report...';

  @override
  String get reportLabel => 'Report';

  @override
  String get nurseAssigned => 'Nurse Assigned';

  @override
  String get nurseOnTheWay => 'Nurse On The Way';

  @override
  String get nurseHasArrived => 'Nurse Has Arrived';

  @override
  String get serviceInProgressLabel => 'Service In Progress';

  @override
  String get waitingNurseDesc =>
      'Waiting for the nurse to head to your location.';

  @override
  String get nurseHeadingDesc =>
      'The nurse is heading to your location right now.';

  @override
  String get nurseOutsideDesc =>
      'Nurse is outside. Please provide the START CODE.';

  @override
  String get nurseProvidingDesc =>
      'The nurse is currently providing the service.';

  @override
  String get trackingDesc => 'We are tracking your appointment.';

  @override
  String get trackingTitle => 'Tracking';

  @override
  String get unitMinutes => 'min';

  @override
  String get unitHours => 'h';

  @override
  String get unitMeters => 'm';

  @override
  String get unitKilometers => 'km';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryPopular => 'Popular';

  @override
  String get categoryQuick => 'Quick';

  @override
  String get categorySpecialized => 'Specialized';

  @override
  String get categoryLongTerm => 'Long-term';

  @override
  String get serviceWoundCareTitle => 'Wound Care';

  @override
  String get serviceWoundCareDuration => '30-45 min';

  @override
  String get serviceWoundCareDesc =>
      'Professional wound care and dressing services provided by certified nurses.';

  @override
  String get serviceWoundCareInc1 => 'Professional wound assessment';

  @override
  String get serviceWoundCareInc2 => 'Sterile dressing';

  @override
  String get serviceWoundCareInc3 => 'Wound cleaning';

  @override
  String get serviceWoundCareInc4 => 'Follow-up visits';

  @override
  String get serviceWoundCareInc5 => 'Progress monitoring';

  @override
  String get serviceInjectionsTitle => 'Injections';

  @override
  String get serviceInjectionsDuration => '15-20 min';

  @override
  String get serviceInjectionsDesc =>
      'Safe and painless injection services at your home.';

  @override
  String get serviceInjectionsInc1 => 'All types of injections';

  @override
  String get serviceInjectionsInc2 => 'Proper sterilization';

  @override
  String get serviceInjectionsInc3 => 'Medication administration';

  @override
  String get serviceInjectionsInc4 => 'Post-injection care';

  @override
  String get serviceElderlyCareTitle => 'Elderly Care';

  @override
  String get serviceElderlyCareDuration => '1-4 hours';

  @override
  String get serviceElderlyCareDesc =>
      'Comprehensive care for elderly patients including assistance with daily activities.';

  @override
  String get serviceElderlyCareInc1 => 'Daily activity assistance';

  @override
  String get serviceElderlyCareInc2 => 'Medication management';

  @override
  String get serviceElderlyCareInc3 => 'Vital signs monitoring';

  @override
  String get serviceElderlyCareInc4 => 'Companionship';

  @override
  String get servicePostOpCareTitle => 'Post-Op Care';

  @override
  String get servicePostOpCareDuration => '45-60 min';

  @override
  String get servicePostOpCareDesc =>
      'Post-operative care services to ensure smooth recovery after surgery.';

  @override
  String get servicePostOpCareInc1 => 'Surgical wound care';

  @override
  String get servicePostOpCareInc2 => 'Pain management';

  @override
  String get servicePostOpCareInc3 => 'Medication administration';

  @override
  String get servicePostOpCareInc4 => 'Vital signs monitoring';

  @override
  String get serviceBabyCareTitle => 'Baby Care';

  @override
  String get serviceBabyCareDuration => '2-3 hours';

  @override
  String get serviceBabyCareDesc =>
      'Professional newborn and infant care services.';

  @override
  String get serviceBabyCareInc1 => 'Newborn monitoring';

  @override
  String get serviceBabyCareInc2 => 'Feeding assistance';

  @override
  String get serviceBabyCareInc3 => 'Bathing';

  @override
  String get serviceBabyCareInc4 => 'Development assessment';

  @override
  String get serviceIvTherapyTitle => 'IV Therapy';

  @override
  String get serviceIvTherapyDuration => '45-60 min';

  @override
  String get serviceIvTherapyDesc =>
      'Intravenous fluid and medication administration';

  @override
  String get serviceIvTherapyInc1 => 'IV line insertion';

  @override
  String get serviceIvTherapyInc2 => 'Medication administration';

  @override
  String get serviceIvTherapyInc3 => 'Fluid therapy';

  @override
  String get serviceIvTherapyInc4 => 'Monitoring';

  @override
  String get serviceCatheterCareTitle => 'Catheter Care';

  @override
  String get serviceCatheterCareDuration => '30-40 min';

  @override
  String get serviceCatheterCareDesc =>
      'Professional catheter insertion, maintenance, and care services.';

  @override
  String get serviceCatheterCareInc1 => 'Catheter insertion';

  @override
  String get serviceCatheterCareInc2 => 'Regular maintenance';

  @override
  String get serviceCatheterCareInc3 => 'Infection prevention';

  @override
  String get serviceCatheterCareInc4 => 'Patient education';

  @override
  String get serviceVitalSignsTitle => 'Vital Signs';

  @override
  String get serviceVitalSignsDuration => '20-30 min';

  @override
  String get serviceVitalSignsDesc =>
      'Complete vital signs monitoring with detailed reporting.';

  @override
  String get serviceVitalSignsInc1 => 'Blood pressure';

  @override
  String get serviceVitalSignsInc2 => 'Temperature';

  @override
  String get serviceVitalSignsInc3 => 'Heart rate';

  @override
  String get serviceVitalSignsInc4 => 'Oxygen saturation';

  @override
  String get serviceVitalSignsInc5 => 'Health report';

  @override
  String get serviceBloodDrawTitle => 'Blood Draw';

  @override
  String get serviceBloodDrawDuration => '15 min';

  @override
  String get serviceBloodDrawDesc =>
      'Professional blood sample collection at your home.';

  @override
  String get serviceBloodDrawInc1 => 'Blood sample collection';

  @override
  String get serviceBloodDrawInc2 => 'Proper labeling';

  @override
  String get serviceBloodDrawInc3 => 'Lab delivery';

  @override
  String get serviceBloodDrawInc4 => 'Results coordination';

  @override
  String get servicePhysiotherapyTitle => 'Physiotherapy';

  @override
  String get servicePhysiotherapyDuration => '60-90 min';

  @override
  String get servicePhysiotherapyDesc =>
      'Home physiotherapy sessions for rehabilitation and mobility.';

  @override
  String get servicePhysiotherapyInc1 => 'Assessment';

  @override
  String get servicePhysiotherapyInc2 => 'Exercise therapy';

  @override
  String get servicePhysiotherapyInc3 => 'Mobility training';

  @override
  String get servicePhysiotherapyInc4 => 'Progress tracking';

  @override
  String get categoryAllServices => 'All Services';

  @override
  String get categoryPostSurgery => 'Post-Surgery';

  @override
  String get categoryElderlyCare => 'Elderly Care';

  @override
  String get categoryInjections => 'Injections';

  @override
  String get categoryWoundCare => 'Wound Care';

  @override
  String get categoryOrthopedic => 'Orthopedic';

  @override
  String get servicePostSurgicalCareTitle => 'Post-Surgical Care';

  @override
  String get servicePostSurgicalCareDesc =>
      'Professional nursing care for patients recovering from surgery';

  @override
  String get servicePostSurgicalCareDuration => '2-3 hours';

  @override
  String get servicePostSurgicalCareInc1 => 'Wound dressing and care';

  @override
  String get servicePostSurgicalCareInc2 => 'Pain management assistance';

  @override
  String get servicePostSurgicalCareInc3 => 'Vital signs monitoring';

  @override
  String get servicePostSurgicalCareInc4 => 'Medication administration';

  @override
  String get servicePostSurgicalCareInc5 => 'Post-operative exercises guidance';

  @override
  String get servicePostSurgicalCareInc6 => 'Infection prevention measures';

  @override
  String get serviceChronicDiseaseTitle => 'Chronic Disease Management';

  @override
  String get serviceChronicDiseaseDesc =>
      'Ongoing care for diabetes, hypertension, and more';

  @override
  String get serviceChronicDiseaseDuration => '2-3 hours';

  @override
  String get serviceChronicDiseaseInc1 => 'Blood sugar monitoring';

  @override
  String get serviceChronicDiseaseInc2 => 'Blood pressure checks';

  @override
  String get serviceChronicDiseaseInc3 => 'Medication management';

  @override
  String get serviceChronicDiseaseInc4 => 'Diet counseling';

  @override
  String get serviceChronicDiseaseInc5 => 'Exercise guidance';

  @override
  String get serviceChronicDiseaseInc6 => 'Health education';

  @override
  String get serviceIvTherapyDurationShort => '30-60 min';

  @override
  String get serviceIvTherapyInc5 => 'Post-procedure care';

  @override
  String get serviceImScInjectionsTitle => 'IM/SC Injections';

  @override
  String get serviceImScInjectionsDesc =>
      'Intramuscular and subcutaneous injections';

  @override
  String get serviceImScInjectionsDuration => '15-20 min';

  @override
  String get serviceImScInjectionsInc1 => 'Injection administration';

  @override
  String get serviceImScInjectionsInc2 => 'Site preparation';

  @override
  String get serviceImScInjectionsInc3 => 'Post-injection monitoring';

  @override
  String get serviceImScInjectionsInc4 => 'Proper disposal of materials';

  @override
  String get serviceWoundDressingTitle => 'Wound Dressing';

  @override
  String get serviceWoundDressingDesc =>
      'Professional wound cleaning and dressing';

  @override
  String get serviceWoundDressingDuration => '30-45 min';

  @override
  String get serviceWoundDressingInc1 => 'Wound assessment';

  @override
  String get serviceWoundDressingInc2 => 'Cleaning and disinfection';

  @override
  String get serviceWoundDressingInc3 => 'Sterile dressing application';

  @override
  String get serviceWoundDressingInc4 => 'Infection monitoring';

  @override
  String get serviceWoundDressingInc5 => 'Care instructions';

  @override
  String get serviceBurnCareTitle => 'Burn Care';

  @override
  String get serviceBurnCareDesc => 'Specialized care for burn injuries';

  @override
  String get serviceBurnCareDuration => '45-60 min';

  @override
  String get serviceBurnCareInc1 => 'Burn assessment';

  @override
  String get serviceBurnCareInc2 => 'Wound cleaning';

  @override
  String get serviceBurnCareInc3 => 'Specialized dressing';

  @override
  String get serviceBurnCareInc4 => 'Pain management';

  @override
  String get serviceBurnCareInc5 => 'Healing monitoring';

  @override
  String get serviceFractureCareTitle => 'Fracture Care';

  @override
  String get serviceFractureCareDesc =>
      'Care for patients with broken bones or fractures';

  @override
  String get serviceFractureCareDuration => '1-2 hours';

  @override
  String get serviceFractureCareInc1 => 'Cast care instructions';

  @override
  String get serviceFractureCareInc2 => 'Pain management';

  @override
  String get serviceFractureCareInc3 => 'Mobility assistance';

  @override
  String get serviceFractureCareInc4 => 'Physical therapy exercises';

  @override
  String get serviceFractureCareInc5 => 'Swelling monitoring';

  @override
  String get filterServices => 'Filter Services';

  @override
  String get reset => 'Reset';

  @override
  String get sortBy => 'Sort By';

  @override
  String get sortRecommended => 'Recommended';

  @override
  String get sortPriceLowToHigh => 'Price: Low to High';

  @override
  String get sortPriceHighToLow => 'Price: High to Low';

  @override
  String get sortHighestRated => 'Highest Rated';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get nursingServicesHeader => 'Nursing\nServices';

  @override
  String nursingServicesSubtitle(Object count) {
    return 'Explore $count premium at-home treatments.';
  }

  @override
  String get searchTreatments => 'Search treatments...';

  @override
  String get noServicesFound => 'No services found';

  @override
  String get tryDifferentSearch => 'Try a different search or category';

  @override
  String priceEgp(Object price) {
    return '$price EGP';
  }

  @override
  String get ourServices => 'Our Services';

  @override
  String get servicesSubtitle => 'Professional healthcare at your doorstep';

  @override
  String get searchServices => 'Search services...';

  @override
  String get popularServices => '🔥 Popular Services';

  @override
  String get allServices => '📋 All Services';

  @override
  String get popularLabel => 'Popular';

  @override
  String get tryAdjustingFilters => 'Try adjusting your search or filters';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get shareComingSoon => 'Share feature coming soon!';

  @override
  String get professionalService => 'Professional Service';

  @override
  String reviewsCount(Object count) {
    return '$count reviews';
  }

  @override
  String bookingsCount(Object count) {
    return '$count bookings';
  }

  @override
  String get price => 'Price';

  @override
  String get duration => 'Duration';

  @override
  String get response => 'Response';

  @override
  String get lessThan5Min => '< 5 min';

  @override
  String get highlightCertified => 'Certified';

  @override
  String get highlightCertifiedDesc => 'Licensed nurses';

  @override
  String get highlightOnTime => 'On-Time';

  @override
  String get highlightOnTimeDesc => '98% punctual';

  @override
  String get highlightTrusted => 'Trusted';

  @override
  String get highlightTrustedDesc => '5.2k+ served';

  @override
  String get highlightSupport => '24/7';

  @override
  String get highlightSupportDesc => 'Support';

  @override
  String get tabIncludes => 'Includes';

  @override
  String get tabReviews => 'Reviews';

  @override
  String get tabFaq => 'FAQ';

  @override
  String get whatsIncluded => 'What\'s Included';

  @override
  String get review1Name => 'Ahmed M.';

  @override
  String get review1Comment =>
      'Excellent service! The nurse was very professional.';

  @override
  String get review2Name => 'Fatima K.';

  @override
  String get review2Comment =>
      'Very satisfied with the care provided. Highly recommend!';

  @override
  String get review3Name => 'Mohamed S.';

  @override
  String get review3Comment => 'Good service, nurse arrived on time.';

  @override
  String get timeAgo2Days => '2 days ago';

  @override
  String get timeAgo1Week => '1 week ago';

  @override
  String get timeAgo2Weeks => '2 weeks ago';

  @override
  String get faq1Q => 'How do I prepare for the service?';

  @override
  String get faq1A =>
      'Ensure a clean, comfortable space for the nurse to work. Have any relevant medical documents ready.';

  @override
  String get faq2Q => 'Can I reschedule my booking?';

  @override
  String get faq2A =>
      'Yes, you can reschedule up to 2 hours before your appointment without any charges.';

  @override
  String get faq3Q => 'What if I need to cancel?';

  @override
  String get faq3A =>
      'Cancellations made 2+ hours before are free. Late cancellations may incur a small fee.';

  @override
  String get verifiedNursesOnly => 'Verified Nurses Only';

  @override
  String get verifiedNursesDesc =>
      'All nurses are licensed, background-checked, and highly rated by patients.';

  @override
  String get satisfactionGuarantee => 'Satisfaction Guarantee';

  @override
  String get satisfactionGuaranteeDesc => '100% Money back if not satisfied';

  @override
  String get freeReschedule => 'Free Reschedule';

  @override
  String get easyRefund => 'Easy Refund';

  @override
  String get support247 => '24/7 Support';

  @override
  String get totalPrice => 'Total Price';

  @override
  String get perVisit => '/visit';

  @override
  String get bookNow => 'Book Now';

  @override
  String get serviceUnavailable =>
      'Service is currently unavailable. Please try another service.';
}
