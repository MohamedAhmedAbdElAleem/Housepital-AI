// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Housepital Staff';

  @override
  String get home => 'Home';

  @override
  String get history => 'History';

  @override
  String get wallet => 'Wallet';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get nurse => 'Nurse';

  @override
  String get nurseMale => 'Male Nurse';

  @override
  String get nurseFemale => 'Female Nurse';

  @override
  String get online => 'AVAILABLE';

  @override
  String get offline => 'OFFLINE';

  @override
  String get goOnlineToStart => 'Go online to start';

  @override
  String get visibleToPatients => 'You are visible to patients';

  @override
  String get scanningPatients => 'Scanning for patients nearby...';

  @override
  String get requestsAppearAuto => 'Requests will appear automatically';

  @override
  String get newRequest => 'NEW REQUEST';

  @override
  String get patientWaiting => 'A patient is waiting for your care';

  @override
  String get viewVisitDetails => 'VIEW VISIT DETAILS';

  @override
  String get accept => 'ACCEPT';

  @override
  String get decline => 'DECLINE';

  @override
  String get close => 'CLOSE';

  @override
  String get visitInfo => 'Visit Information';

  @override
  String get serviceRequested => 'Service Requested';

  @override
  String get timing => 'Timing';

  @override
  String get asapRequest => 'ASAP REQUEST';

  @override
  String get scheduledVisit => 'SCHEDULED VISIT';

  @override
  String get scheduleTitle => 'My Schedule';

  @override
  String get location => 'Location';

  @override
  String get patientNotes => 'Patient Notes';

  @override
  String get totalEarning => 'Total Earning';

  @override
  String get egp => 'EGP';

  @override
  String get offerAccepted => 'OFFER ACCEPTED';

  @override
  String get waitingPatientConfirm => 'Waiting for patient confirmation...';

  @override
  String get verifyVisit => 'VERIFY VISIT';

  @override
  String get enterSecurityCode => 'Enter Security Code';

  @override
  String get askPatientCode => 'Ask the patient for the 4-digit code';

  @override
  String get startVisit => 'START VISIT';

  @override
  String get cancelVisit => 'Cancel Visit';

  @override
  String get visitInProgress => 'VISIT IN PROGRESS';

  @override
  String get liveDuration => 'LIVE DURATION';

  @override
  String get sessionOverview => 'Session Overview';

  @override
  String get started => 'Started';

  @override
  String get type => 'Type';

  @override
  String get inPerson => 'In-Person';

  @override
  String get patientRecord => 'Patient Record';

  @override
  String get serviceDetails => 'SERVICE DETAILS';

  @override
  String get completeReportForm => 'Complete the report form';

  @override
  String fieldsRemaining(int count) {
    return '$count fields remaining';
  }

  @override
  String get visitReport => 'VISIT REPORT';

  @override
  String get completeVisit => 'COMPLETE VISIT';

  @override
  String get fillVitalsToComplete =>
      'Please fill all vital information to complete';

  @override
  String get confirmCompleteTitle => 'Complete Visit?';

  @override
  String get confirmCompleteSub =>
      'This will finalize the visit and deduct the platform commission from your wallet.';

  @override
  String get goBack => 'Go Back';

  @override
  String get visitCompleted => 'Visit Completed!';

  @override
  String get visitCompletedSub =>
      'Excellent work! The visit report has been generated and the session is now finalized.';

  @override
  String get documentation => 'DOCUMENTATION';

  @override
  String get sharePdf => 'SHARE PDF';

  @override
  String get previewReport => 'PREVIEW REPORT';

  @override
  String get backToHome => 'BACK TO HOME';

  @override
  String get patientStatus => 'Patient Status';

  @override
  String get assessCondition => 'Assess overall condition';

  @override
  String get overallCondition => 'Overall Condition *';

  @override
  String get consciousnessLevel => 'Consciousness Level *';

  @override
  String get painLevel => 'Pain Level';

  @override
  String get mobility => 'Mobility';

  @override
  String get woundCondition => 'Wound / IV Site Condition';

  @override
  String get vitalSigns => 'Vital Signs';

  @override
  String get requiredBeforeComplete => 'Required before completing';

  @override
  String get bloodPressure => 'Blood Pressure';

  @override
  String get heartRate => 'Heart Rate';

  @override
  String get temperature => 'Temperature';

  @override
  String get oxygenSaturation => 'Oxygen Saturation (SpO₂)';

  @override
  String get optionalVitals => 'Respiratory Rate, Blood Sugar, Weight';

  @override
  String get hideOptional => 'Hide Optional Vitals';

  @override
  String get showOptional => '+ Respiratory Rate, Blood Sugar, Weight';

  @override
  String get careProvided => 'Care Provided';

  @override
  String get whatWasDone => 'What was done during the visit';

  @override
  String get servicesPerformed => 'Services Performed *';

  @override
  String get medicationsGiven => 'Medications Given';

  @override
  String get addMedication => 'Add Medication';

  @override
  String get proceduresPerformed => 'Procedures Performed';

  @override
  String get patientCooperation => 'Patient Cooperation';

  @override
  String get notesObservations => 'Notes & Observations';

  @override
  String get clinicalObservations => 'Clinical Observations';

  @override
  String get familyPresent => 'Family / Caregiver Present';

  @override
  String get homeEnvironment => 'Home Environment';

  @override
  String get familyConcerns => 'Patient / Family Concerns';

  @override
  String get followUpAlerts => 'Follow-up & Alerts';

  @override
  String get nextSteps => 'Next steps for this patient';

  @override
  String get followUpRequired => 'Follow-up Required?';

  @override
  String get urgencyLevel => 'Urgency Level';

  @override
  String get recommendedActions => 'Recommended Actions';

  @override
  String get alertCareTeam => 'Alert for Care Team';

  @override
  String get myWallet => 'My Wallet';

  @override
  String get rechargeWallet => 'Recharge Wallet';

  @override
  String minThreshold(String amount) {
    return 'Min: $amount EGP';
  }

  @override
  String commission(String rate) {
    return 'Commission: $rate%';
  }

  @override
  String get accountRestricted => 'Account Restricted';

  @override
  String get transactionHistory => 'Transaction History';

  @override
  String get myProfile => 'My Profile';

  @override
  String get editProfileData => 'Edit Profile Data';

  @override
  String get personalDetails => 'Personal Details';

  @override
  String get professionalDetails => 'Professional Details';

  @override
  String get skills => 'Skills';

  @override
  String get credentials => 'Professional Credentials';

  @override
  String get serviceAreas => 'Service Areas';

  @override
  String get performanceReviews => 'Performance & Reviews';

  @override
  String get signOut => 'Sign Out';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get yourWorkZone => 'Your Work Zone';

  @override
  String get change => 'Change';

  @override
  String get mapEditingSoon => 'Map Editing Coming Soon';

  @override
  String get appPreferences => 'App Preferences';

  @override
  String get changePassword => 'Change Password';

  @override
  String get darkThemeEnabled => 'Dark theme enabled';

  @override
  String get lightThemeEnabled => 'Light theme enabled';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get closeButton => 'Close';

  @override
  String get passwordUpdated => 'Password updated successfully!';

  @override
  String get privacyPolicyContent =>
      'Your privacy is important to us. Housepital securely encrypts all user and patient data.';

  @override
  String get termsOfServiceContent =>
      'Housepital terms of service govern your usage of this platform.';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get appVersion => 'Housepital Staff App v1.0.0';

  @override
  String get security => 'Security';

  @override
  String get about => 'About';

  @override
  String get noPerformanceData => 'No performance data available';

  @override
  String get myPerformance => 'My Performance';

  @override
  String get patientReviewsTitle => 'Patient Reviews';

  @override
  String get reviewsCountText => 'Reviews';

  @override
  String get visitsStat => 'Visits';

  @override
  String get rateStat => 'Rate';

  @override
  String get noReviewsYet => 'No Reviews Yet';

  @override
  String get patientFeedbackDesc =>
      'Patient feedback will appear here once you start completing visits.';

  @override
  String get noSessionsYet => 'No sessions yet';

  @override
  String get historyEmptyDesc =>
      'Your completed and cancelled visits will appear here.';

  @override
  String get completedStatus => 'Completed';

  @override
  String get cancelledStatus => 'Cancelled';

  @override
  String get durationLabel => 'Duration';

  @override
  String get failedToLoadPaymentInfo => 'Failed to load payment info';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get blockedLabel => 'BLOCKED';

  @override
  String get walletBlockedDesc =>
      'Your wallet balance has exceeded the minimum threshold.';

  @override
  String get rechargeToUnblockDesc =>
      'Recharge your wallet to unblock your account.';

  @override
  String get rechargeToUnblockButton => 'Recharge to Unblock';

  @override
  String get myReceiptsTitle => 'My Receipts';

  @override
  String get trackReceiptsDesc => 'Track the status of your recharge requests';

  @override
  String get approvedStatus => 'APPROVED';

  @override
  String get rejectedStatus => 'REJECTED';

  @override
  String get pendingStatus => 'PENDING';

  @override
  String get reasonLabel => 'Reason';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get transferAmountDesc =>
      'Transfer the amount then upload your receipt.';

  @override
  String get paymentMethodLabel => 'Payment Method';

  @override
  String get instapayDetails => '📱 Instapay Details';

  @override
  String get mobileWalletDetails => '📱 Mobile Wallet Details';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get nameLabel => 'Name';

  @override
  String get linkLabel => 'Link';

  @override
  String get amountLabel => 'Amount';

  @override
  String get min10Label => 'Min 10';

  @override
  String get tapToUploadReceipt => 'Tap to upload receipt photo';

  @override
  String get receiptUploaded => 'Receipt uploaded ✓';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get submittingBtn => 'Submitting...';

  @override
  String get submitReceiptBtn => 'Submit Receipt';

  @override
  String get viewStatus => 'View Status';

  @override
  String get finishSetup => 'Finish Setup';

  @override
  String get fixNow => 'Fix Now';

  @override
  String get profileApprovalRequired =>
      'You cannot receive requests until your profile is approved.';

  @override
  String get reviewDuration =>
      'We are reviewing your profile. This usually takes 24h.';

  @override
  String get updateDocuments => 'Please update your documents.';
}
