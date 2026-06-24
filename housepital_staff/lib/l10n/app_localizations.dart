import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'Housepital Staff'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @nurse.
  ///
  /// In en, this message translates to:
  /// **'Nurse'**
  String get nurse;

  /// No description provided for @nurseMale.
  ///
  /// In en, this message translates to:
  /// **'Male Nurse'**
  String get nurseMale;

  /// No description provided for @nurseFemale.
  ///
  /// In en, this message translates to:
  /// **'Female Nurse'**
  String get nurseFemale;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'AVAILABLE'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'OFFLINE'**
  String get offline;

  /// No description provided for @goOnlineToStart.
  ///
  /// In en, this message translates to:
  /// **'Go online to start'**
  String get goOnlineToStart;

  /// No description provided for @visibleToPatients.
  ///
  /// In en, this message translates to:
  /// **'You are visible to patients'**
  String get visibleToPatients;

  /// No description provided for @scanningPatients.
  ///
  /// In en, this message translates to:
  /// **'Scanning for patients nearby...'**
  String get scanningPatients;

  /// No description provided for @requestsAppearAuto.
  ///
  /// In en, this message translates to:
  /// **'Requests will appear automatically'**
  String get requestsAppearAuto;

  /// No description provided for @newRequest.
  ///
  /// In en, this message translates to:
  /// **'NEW REQUEST'**
  String get newRequest;

  /// No description provided for @patientWaiting.
  ///
  /// In en, this message translates to:
  /// **'A patient is waiting for your care'**
  String get patientWaiting;

  /// No description provided for @viewVisitDetails.
  ///
  /// In en, this message translates to:
  /// **'VIEW VISIT DETAILS'**
  String get viewVisitDetails;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'ACCEPT'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'DECLINE'**
  String get decline;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'CLOSE'**
  String get close;

  /// No description provided for @visitInfo.
  ///
  /// In en, this message translates to:
  /// **'Visit Information'**
  String get visitInfo;

  /// No description provided for @serviceRequested.
  ///
  /// In en, this message translates to:
  /// **'Service Requested'**
  String get serviceRequested;

  /// No description provided for @timing.
  ///
  /// In en, this message translates to:
  /// **'Timing'**
  String get timing;

  /// No description provided for @asapRequest.
  ///
  /// In en, this message translates to:
  /// **'ASAP REQUEST'**
  String get asapRequest;

  /// No description provided for @scheduledVisit.
  ///
  /// In en, this message translates to:
  /// **'SCHEDULED VISIT'**
  String get scheduledVisit;

  /// No description provided for @scheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'My Schedule'**
  String get scheduleTitle;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @patientNotes.
  ///
  /// In en, this message translates to:
  /// **'Patient Notes'**
  String get patientNotes;

  /// No description provided for @totalEarning.
  ///
  /// In en, this message translates to:
  /// **'Total Earning'**
  String get totalEarning;

  /// No description provided for @egp.
  ///
  /// In en, this message translates to:
  /// **'EGP'**
  String get egp;

  /// No description provided for @offerAccepted.
  ///
  /// In en, this message translates to:
  /// **'OFFER ACCEPTED'**
  String get offerAccepted;

  /// No description provided for @waitingPatientConfirm.
  ///
  /// In en, this message translates to:
  /// **'Waiting for patient confirmation...'**
  String get waitingPatientConfirm;

  /// No description provided for @verifyVisit.
  ///
  /// In en, this message translates to:
  /// **'VERIFY VISIT'**
  String get verifyVisit;

  /// No description provided for @enterSecurityCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Security Code'**
  String get enterSecurityCode;

  /// No description provided for @askPatientCode.
  ///
  /// In en, this message translates to:
  /// **'Ask the patient for the 4-digit code'**
  String get askPatientCode;

  /// No description provided for @startVisit.
  ///
  /// In en, this message translates to:
  /// **'START VISIT'**
  String get startVisit;

  /// No description provided for @cancelVisit.
  ///
  /// In en, this message translates to:
  /// **'Cancel Visit'**
  String get cancelVisit;

  /// No description provided for @visitInProgress.
  ///
  /// In en, this message translates to:
  /// **'VISIT IN PROGRESS'**
  String get visitInProgress;

  /// No description provided for @liveDuration.
  ///
  /// In en, this message translates to:
  /// **'LIVE DURATION'**
  String get liveDuration;

  /// No description provided for @sessionOverview.
  ///
  /// In en, this message translates to:
  /// **'Session Overview'**
  String get sessionOverview;

  /// No description provided for @started.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get started;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @inPerson.
  ///
  /// In en, this message translates to:
  /// **'In-Person'**
  String get inPerson;

  /// No description provided for @patientRecord.
  ///
  /// In en, this message translates to:
  /// **'Patient Record'**
  String get patientRecord;

  /// No description provided for @serviceDetails.
  ///
  /// In en, this message translates to:
  /// **'SERVICE DETAILS'**
  String get serviceDetails;

  /// No description provided for @completeReportForm.
  ///
  /// In en, this message translates to:
  /// **'Complete the report form'**
  String get completeReportForm;

  /// No description provided for @fieldsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} fields remaining'**
  String fieldsRemaining(int count);

  /// No description provided for @visitReport.
  ///
  /// In en, this message translates to:
  /// **'VISIT REPORT'**
  String get visitReport;

  /// No description provided for @completeVisit.
  ///
  /// In en, this message translates to:
  /// **'COMPLETE VISIT'**
  String get completeVisit;

  /// No description provided for @fillVitalsToComplete.
  ///
  /// In en, this message translates to:
  /// **'Please fill all vital information to complete'**
  String get fillVitalsToComplete;

  /// No description provided for @confirmCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete Visit?'**
  String get confirmCompleteTitle;

  /// No description provided for @confirmCompleteSub.
  ///
  /// In en, this message translates to:
  /// **'This will finalize the visit and deduct the platform commission from your wallet.'**
  String get confirmCompleteSub;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @visitCompleted.
  ///
  /// In en, this message translates to:
  /// **'Visit Completed!'**
  String get visitCompleted;

  /// No description provided for @visitCompletedSub.
  ///
  /// In en, this message translates to:
  /// **'Excellent work! The visit report has been generated and the session is now finalized.'**
  String get visitCompletedSub;

  /// No description provided for @documentation.
  ///
  /// In en, this message translates to:
  /// **'DOCUMENTATION'**
  String get documentation;

  /// No description provided for @sharePdf.
  ///
  /// In en, this message translates to:
  /// **'SHARE PDF'**
  String get sharePdf;

  /// No description provided for @previewReport.
  ///
  /// In en, this message translates to:
  /// **'PREVIEW REPORT'**
  String get previewReport;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'BACK TO HOME'**
  String get backToHome;

  /// No description provided for @patientStatus.
  ///
  /// In en, this message translates to:
  /// **'Patient Status'**
  String get patientStatus;

  /// No description provided for @assessCondition.
  ///
  /// In en, this message translates to:
  /// **'Assess overall condition'**
  String get assessCondition;

  /// No description provided for @overallCondition.
  ///
  /// In en, this message translates to:
  /// **'Overall Condition *'**
  String get overallCondition;

  /// No description provided for @consciousnessLevel.
  ///
  /// In en, this message translates to:
  /// **'Consciousness Level *'**
  String get consciousnessLevel;

  /// No description provided for @painLevel.
  ///
  /// In en, this message translates to:
  /// **'Pain Level'**
  String get painLevel;

  /// No description provided for @mobility.
  ///
  /// In en, this message translates to:
  /// **'Mobility'**
  String get mobility;

  /// No description provided for @woundCondition.
  ///
  /// In en, this message translates to:
  /// **'Wound / IV Site Condition'**
  String get woundCondition;

  /// No description provided for @vitalSigns.
  ///
  /// In en, this message translates to:
  /// **'Vital Signs'**
  String get vitalSigns;

  /// No description provided for @requiredBeforeComplete.
  ///
  /// In en, this message translates to:
  /// **'Required before completing'**
  String get requiredBeforeComplete;

  /// No description provided for @bloodPressure.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure'**
  String get bloodPressure;

  /// No description provided for @heartRate.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate'**
  String get heartRate;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @oxygenSaturation.
  ///
  /// In en, this message translates to:
  /// **'Oxygen Saturation (SpO₂)'**
  String get oxygenSaturation;

  /// No description provided for @optionalVitals.
  ///
  /// In en, this message translates to:
  /// **'Respiratory Rate, Blood Sugar, Weight'**
  String get optionalVitals;

  /// No description provided for @hideOptional.
  ///
  /// In en, this message translates to:
  /// **'Hide Optional Vitals'**
  String get hideOptional;

  /// No description provided for @showOptional.
  ///
  /// In en, this message translates to:
  /// **'+ Respiratory Rate, Blood Sugar, Weight'**
  String get showOptional;

  /// No description provided for @careProvided.
  ///
  /// In en, this message translates to:
  /// **'Care Provided'**
  String get careProvided;

  /// No description provided for @whatWasDone.
  ///
  /// In en, this message translates to:
  /// **'What was done during the visit'**
  String get whatWasDone;

  /// No description provided for @servicesPerformed.
  ///
  /// In en, this message translates to:
  /// **'Services Performed *'**
  String get servicesPerformed;

  /// No description provided for @medicationsGiven.
  ///
  /// In en, this message translates to:
  /// **'Medications Given'**
  String get medicationsGiven;

  /// No description provided for @addMedication.
  ///
  /// In en, this message translates to:
  /// **'Add Medication'**
  String get addMedication;

  /// No description provided for @proceduresPerformed.
  ///
  /// In en, this message translates to:
  /// **'Procedures Performed'**
  String get proceduresPerformed;

  /// No description provided for @patientCooperation.
  ///
  /// In en, this message translates to:
  /// **'Patient Cooperation'**
  String get patientCooperation;

  /// No description provided for @notesObservations.
  ///
  /// In en, this message translates to:
  /// **'Notes & Observations'**
  String get notesObservations;

  /// No description provided for @clinicalObservations.
  ///
  /// In en, this message translates to:
  /// **'Clinical Observations'**
  String get clinicalObservations;

  /// No description provided for @familyPresent.
  ///
  /// In en, this message translates to:
  /// **'Family / Caregiver Present'**
  String get familyPresent;

  /// No description provided for @homeEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Home Environment'**
  String get homeEnvironment;

  /// No description provided for @familyConcerns.
  ///
  /// In en, this message translates to:
  /// **'Patient / Family Concerns'**
  String get familyConcerns;

  /// No description provided for @followUpAlerts.
  ///
  /// In en, this message translates to:
  /// **'Follow-up & Alerts'**
  String get followUpAlerts;

  /// No description provided for @nextSteps.
  ///
  /// In en, this message translates to:
  /// **'Next steps for this patient'**
  String get nextSteps;

  /// No description provided for @followUpRequired.
  ///
  /// In en, this message translates to:
  /// **'Follow-up Required?'**
  String get followUpRequired;

  /// No description provided for @urgencyLevel.
  ///
  /// In en, this message translates to:
  /// **'Urgency Level'**
  String get urgencyLevel;

  /// No description provided for @recommendedActions.
  ///
  /// In en, this message translates to:
  /// **'Recommended Actions'**
  String get recommendedActions;

  /// No description provided for @alertCareTeam.
  ///
  /// In en, this message translates to:
  /// **'Alert for Care Team'**
  String get alertCareTeam;

  /// No description provided for @myWallet.
  ///
  /// In en, this message translates to:
  /// **'My Wallet'**
  String get myWallet;

  /// No description provided for @rechargeWallet.
  ///
  /// In en, this message translates to:
  /// **'Recharge Wallet'**
  String get rechargeWallet;

  /// No description provided for @minThreshold.
  ///
  /// In en, this message translates to:
  /// **'Min: {amount} EGP'**
  String minThreshold(String amount);

  /// No description provided for @commission.
  ///
  /// In en, this message translates to:
  /// **'Commission: {rate}%'**
  String commission(String rate);

  /// No description provided for @accountRestricted.
  ///
  /// In en, this message translates to:
  /// **'Account Restricted'**
  String get accountRestricted;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @editProfileData.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile Data'**
  String get editProfileData;

  /// No description provided for @personalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personalDetails;

  /// No description provided for @professionalDetails.
  ///
  /// In en, this message translates to:
  /// **'Professional Details'**
  String get professionalDetails;

  /// No description provided for @skills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get skills;

  /// No description provided for @credentials.
  ///
  /// In en, this message translates to:
  /// **'Professional Credentials'**
  String get credentials;

  /// No description provided for @serviceAreas.
  ///
  /// In en, this message translates to:
  /// **'Service Areas'**
  String get serviceAreas;

  /// No description provided for @performanceReviews.
  ///
  /// In en, this message translates to:
  /// **'Performance & Reviews'**
  String get performanceReviews;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @yourWorkZone.
  ///
  /// In en, this message translates to:
  /// **'Your Work Zone'**
  String get yourWorkZone;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @mapEditingSoon.
  ///
  /// In en, this message translates to:
  /// **'Map Editing Coming Soon'**
  String get mapEditingSoon;

  /// No description provided for @appPreferences.
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get appPreferences;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @darkThemeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Dark theme enabled'**
  String get darkThemeEnabled;

  /// No description provided for @lightThemeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Light theme enabled'**
  String get lightThemeEnabled;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully!'**
  String get passwordUpdated;

  /// No description provided for @privacyPolicyContent.
  ///
  /// In en, this message translates to:
  /// **'Your privacy is important to us. Housepital securely encrypts all user and patient data.'**
  String get privacyPolicyContent;

  /// No description provided for @termsOfServiceContent.
  ///
  /// In en, this message translates to:
  /// **'Housepital terms of service govern your usage of this platform.'**
  String get termsOfServiceContent;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Housepital Staff App v1.0.0'**
  String get appVersion;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @noPerformanceData.
  ///
  /// In en, this message translates to:
  /// **'No performance data available'**
  String get noPerformanceData;

  /// No description provided for @myPerformance.
  ///
  /// In en, this message translates to:
  /// **'My Performance'**
  String get myPerformance;

  /// No description provided for @patientReviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Patient Reviews'**
  String get patientReviewsTitle;

  /// No description provided for @reviewsCountText.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviewsCountText;

  /// No description provided for @visitsStat.
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get visitsStat;

  /// No description provided for @rateStat.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rateStat;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No Reviews Yet'**
  String get noReviewsYet;

  /// No description provided for @patientFeedbackDesc.
  ///
  /// In en, this message translates to:
  /// **'Patient feedback will appear here once you start completing visits.'**
  String get patientFeedbackDesc;

  /// No description provided for @noSessionsYet.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet'**
  String get noSessionsYet;

  /// No description provided for @historyEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Your completed and cancelled visits will appear here.'**
  String get historyEmptyDesc;

  /// No description provided for @completedStatus.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedStatus;

  /// No description provided for @cancelledStatus.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelledStatus;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// No description provided for @failedToLoadPaymentInfo.
  ///
  /// In en, this message translates to:
  /// **'Failed to load payment info'**
  String get failedToLoadPaymentInfo;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @blockedLabel.
  ///
  /// In en, this message translates to:
  /// **'BLOCKED'**
  String get blockedLabel;

  /// No description provided for @walletBlockedDesc.
  ///
  /// In en, this message translates to:
  /// **'Your wallet balance has exceeded the minimum threshold.'**
  String get walletBlockedDesc;

  /// No description provided for @rechargeToUnblockDesc.
  ///
  /// In en, this message translates to:
  /// **'Recharge your wallet to unblock your account.'**
  String get rechargeToUnblockDesc;

  /// No description provided for @rechargeToUnblockButton.
  ///
  /// In en, this message translates to:
  /// **'Recharge to Unblock'**
  String get rechargeToUnblockButton;

  /// No description provided for @myReceiptsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Receipts'**
  String get myReceiptsTitle;

  /// No description provided for @trackReceiptsDesc.
  ///
  /// In en, this message translates to:
  /// **'Track the status of your recharge requests'**
  String get trackReceiptsDesc;

  /// No description provided for @approvedStatus.
  ///
  /// In en, this message translates to:
  /// **'APPROVED'**
  String get approvedStatus;

  /// No description provided for @rejectedStatus.
  ///
  /// In en, this message translates to:
  /// **'REJECTED'**
  String get rejectedStatus;

  /// No description provided for @pendingStatus.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get pendingStatus;

  /// No description provided for @reasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reasonLabel;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @transferAmountDesc.
  ///
  /// In en, this message translates to:
  /// **'Transfer the amount then upload your receipt.'**
  String get transferAmountDesc;

  /// No description provided for @paymentMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethodLabel;

  /// No description provided for @instapayDetails.
  ///
  /// In en, this message translates to:
  /// **'📱 Instapay Details'**
  String get instapayDetails;

  /// No description provided for @mobileWalletDetails.
  ///
  /// In en, this message translates to:
  /// **'📱 Mobile Wallet Details'**
  String get mobileWalletDetails;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @linkLabel.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get linkLabel;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @min10Label.
  ///
  /// In en, this message translates to:
  /// **'Min 10'**
  String get min10Label;

  /// No description provided for @tapToUploadReceipt.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload receipt photo'**
  String get tapToUploadReceipt;

  /// No description provided for @receiptUploaded.
  ///
  /// In en, this message translates to:
  /// **'Receipt uploaded ✓'**
  String get receiptUploaded;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @submittingBtn.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submittingBtn;

  /// No description provided for @submitReceiptBtn.
  ///
  /// In en, this message translates to:
  /// **'Submit Receipt'**
  String get submitReceiptBtn;

  /// No description provided for @viewStatus.
  ///
  /// In en, this message translates to:
  /// **'View Status'**
  String get viewStatus;

  /// No description provided for @finishSetup.
  ///
  /// In en, this message translates to:
  /// **'Finish Setup'**
  String get finishSetup;

  /// No description provided for @fixNow.
  ///
  /// In en, this message translates to:
  /// **'Fix Now'**
  String get fixNow;

  /// No description provided for @profileApprovalRequired.
  ///
  /// In en, this message translates to:
  /// **'You cannot receive requests until your profile is approved.'**
  String get profileApprovalRequired;

  /// No description provided for @reviewDuration.
  ///
  /// In en, this message translates to:
  /// **'We are reviewing your profile. This usually takes 24h.'**
  String get reviewDuration;

  /// No description provided for @updateDocuments.
  ///
  /// In en, this message translates to:
  /// **'Please update your documents.'**
  String get updateDocuments;

  /// No description provided for @serviceVitalSigns.
  ///
  /// In en, this message translates to:
  /// **'Vital Signs Measurement'**
  String get serviceVitalSigns;

  /// No description provided for @serviceWoundCare.
  ///
  /// In en, this message translates to:
  /// **'Wound Care'**
  String get serviceWoundCare;

  /// No description provided for @serviceMedicationAdmin.
  ///
  /// In en, this message translates to:
  /// **'Medication Administration'**
  String get serviceMedicationAdmin;

  /// No description provided for @serviceIvCare.
  ///
  /// In en, this message translates to:
  /// **'IV Care'**
  String get serviceIvCare;

  /// No description provided for @servicePatientEducation.
  ///
  /// In en, this message translates to:
  /// **'Patient Education'**
  String get servicePatientEducation;

  /// No description provided for @servicePainAssessment.
  ///
  /// In en, this message translates to:
  /// **'Pain Assessment'**
  String get servicePainAssessment;

  /// No description provided for @serviceMobilityAssist.
  ///
  /// In en, this message translates to:
  /// **'Mobility Assistance'**
  String get serviceMobilityAssist;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
