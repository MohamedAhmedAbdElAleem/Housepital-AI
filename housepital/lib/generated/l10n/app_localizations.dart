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

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Housepital'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered Home Healthcare'**
  String get appTagline;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearanceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Appearance & Language'**
  String get appearanceLanguage;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'Professional Care\nAt Your Doorstep'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Desc.
  ///
  /// In en, this message translates to:
  /// **'Get certified nurses and healthcare professionals\ndelivered to your home, on-demand or scheduled'**
  String get onboarding1Desc;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered\nHealthcare Assistant'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Desc.
  ///
  /// In en, this message translates to:
  /// **'Smart recommendations and 24/7 support with\nour intelligent healthcare companion'**
  String get onboarding2Desc;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @skipIntro.
  ///
  /// In en, this message translates to:
  /// **'Skip Intro'**
  String get skipIntro;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get version;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Login to your Housepital account'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @registerHere.
  ///
  /// In en, this message translates to:
  /// **'Register Here'**
  String get registerHere;

  /// No description provided for @orLoginWith.
  ///
  /// In en, this message translates to:
  /// **'Or login with'**
  String get orLoginWith;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @apple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get apple;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please login with password.'**
  String get sessionExpired;

  /// No description provided for @warningEmptyEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get warningEmptyEmail;

  /// No description provided for @warningInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get warningInvalidEmail;

  /// No description provided for @warningEmptyPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get warningEmptyPassword;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get errorInvalidCredentials;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'🔐 Don\'t worry! We\'ll help you reset it'**
  String get forgotPasswordSubtitle;

  /// No description provided for @resetViaEmail.
  ///
  /// In en, this message translates to:
  /// **'Reset via Email'**
  String get resetViaEmail;

  /// No description provided for @sendVerificationCodeDesc.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a verification code'**
  String get sendVerificationCodeDesc;

  /// No description provided for @emailHintForgot.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered email'**
  String get emailHintForgot;

  /// No description provided for @sendCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Code'**
  String get sendCodeButton;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @securityTips.
  ///
  /// In en, this message translates to:
  /// **'Security Tips'**
  String get securityTips;

  /// No description provided for @tipSpamFolder.
  ///
  /// In en, this message translates to:
  /// **'Check your spam folder if you don\'t see the email'**
  String get tipSpamFolder;

  /// No description provided for @tipCodeExpiry.
  ///
  /// In en, this message translates to:
  /// **'Code expires in 10 minutes'**
  String get tipCodeExpiry;

  /// No description provided for @tipNeverShare.
  ///
  /// In en, this message translates to:
  /// **'Never share your code with anyone'**
  String get tipNeverShare;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @otpSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent to your email'**
  String get otpSentSuccess;

  /// No description provided for @otpSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send code'**
  String get otpSendFailed;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternet;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'🏥 Join us for better healthcare'**
  String get registerSubtitle;

  /// No description provided for @registrationStep.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String registrationStep(Object current, Object total);

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get fullNameHint;

  /// No description provided for @mobileLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileLabel;

  /// No description provided for @mobileHint.
  ///
  /// In en, this message translates to:
  /// **'01012345678'**
  String get mobileHint;

  /// No description provided for @passwordHintRegister.
  ///
  /// In en, this message translates to:
  /// **'Create a strong password'**
  String get passwordHintRegister;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get confirmPasswordHint;

  /// No description provided for @agreeTo.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get agreeTo;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Too Short'**
  String get passwordTooShort;

  /// No description provided for @passwordWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get passwordWeak;

  /// No description provided for @passwordMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get passwordMedium;

  /// No description provided for @passwordStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get passwordStrong;

  /// No description provided for @passwordVeryStrong.
  ///
  /// In en, this message translates to:
  /// **'Very Strong'**
  String get passwordVeryStrong;

  /// No description provided for @warningEmptyName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get warningEmptyName;

  /// No description provided for @warningShortName.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 3 characters'**
  String get warningShortName;

  /// No description provided for @warningEmptyMobile.
  ///
  /// In en, this message translates to:
  /// **'Please enter your mobile number'**
  String get warningEmptyMobile;

  /// No description provided for @warningInvalidMobile.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid Egyptian mobile number'**
  String get warningInvalidMobile;

  /// No description provided for @warningEmptyConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get warningEmptyConfirmPassword;

  /// No description provided for @warningPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get warningPasswordMismatch;

  /// No description provided for @warningAgreeTerms.
  ///
  /// In en, this message translates to:
  /// **'Please agree to Terms of Service'**
  String get warningAgreeTerms;

  /// No description provided for @registrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Complete your profile'**
  String get registrationSuccess;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again'**
  String get serverError;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyEmailTitle;

  /// No description provided for @otpVerifySuccess.
  ///
  /// In en, this message translates to:
  /// **'Email verified successfully!'**
  String get otpVerifySuccess;

  /// No description provided for @tooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many failed attempts. Request a new code.'**
  String get tooManyAttempts;

  /// No description provided for @warningCompleteOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter the complete 6-digit code'**
  String get warningCompleteOtp;

  /// No description provided for @invalidOtpRemaining.
  ///
  /// In en, this message translates to:
  /// **'Invalid code. {remaining} attempts remaining.'**
  String invalidOtpRemaining(Object remaining);

  /// No description provided for @accountLocked.
  ///
  /// In en, this message translates to:
  /// **'Account locked! Request a new code.'**
  String get accountLocked;

  /// No description provided for @waitBeforeResend.
  ///
  /// In en, this message translates to:
  /// **'Please wait before requesting new code'**
  String get waitBeforeResend;

  /// No description provided for @newOtpSent.
  ///
  /// In en, this message translates to:
  /// **'New verification code sent!'**
  String get newOtpSent;

  /// No description provided for @resendFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to resend code'**
  String get resendFailed;

  /// No description provided for @codeExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'Code expires in'**
  String get codeExpiresIn;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get enterVerificationCode;

  /// No description provided for @attemptIndicator.
  ///
  /// In en, this message translates to:
  /// **'Attempt {current} of {total}'**
  String attemptIndicator(Object current, Object total);

  /// No description provided for @didntReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get didntReceiveCode;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @verifyEmailButton.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get verifyEmailButton;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @securityNotice.
  ///
  /// In en, this message translates to:
  /// **'Security Notice'**
  String get securityNotice;

  /// No description provided for @securityNoticeDesc.
  ///
  /// In en, this message translates to:
  /// **'Never share this code with anyone. Our team will never ask for it.'**
  String get securityNoticeDesc;

  /// No description provided for @createNewPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Password'**
  String get createNewPasswordTitle;

  /// No description provided for @newPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'🔒 Make it strong and unique'**
  String get newPasswordSubtitle;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordLabel;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'Password Requirements'**
  String get passwordRequirements;

  /// No description provided for @min6Chars.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get min6Chars;

  /// No description provided for @passwordsMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords match'**
  String get passwordsMatch;

  /// No description provided for @resetPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordButton;

  /// No description provided for @passwordTips.
  ///
  /// In en, this message translates to:
  /// **'Password Tips'**
  String get passwordTips;

  /// No description provided for @tipMixChars.
  ///
  /// In en, this message translates to:
  /// **'Use a mix of letters, numbers & symbols'**
  String get tipMixChars;

  /// No description provided for @tipAvoidPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Avoid using personal information'**
  String get tipAvoidPersonalInfo;

  /// No description provided for @tipDontReuse.
  ///
  /// In en, this message translates to:
  /// **'Don\'t reuse passwords from other sites'**
  String get tipDontReuse;

  /// No description provided for @warningEmptyNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get warningEmptyNewPassword;

  /// No description provided for @resetFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to reset password'**
  String get resetFailed;

  /// No description provided for @resetSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Password Reset\nSuccessful! 🎉'**
  String get resetSuccessTitle;

  /// No description provided for @resetSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your password has been changed successfully.\nYou can now login with your new password.'**
  String get resetSuccessSubtitle;

  /// No description provided for @tipPrivatePassword.
  ///
  /// In en, this message translates to:
  /// **'Keep your password private'**
  String get tipPrivatePassword;

  /// No description provided for @tipChangeRegularly.
  ///
  /// In en, this message translates to:
  /// **'Change it every 3-6 months'**
  String get tipChangeRegularly;

  /// No description provided for @tipSignOutUnknown.
  ///
  /// In en, this message translates to:
  /// **'Sign out from unknown devices'**
  String get tipSignOutUnknown;

  /// No description provided for @verificationSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification\nSuccessful! 🎉'**
  String get verificationSuccessTitle;

  /// No description provided for @verificationSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your identity has been verified successfully'**
  String get verificationSuccessSubtitle;

  /// No description provided for @identityVerified.
  ///
  /// In en, this message translates to:
  /// **'Identity Verified'**
  String get identityVerified;

  /// No description provided for @idConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Your ID has been confirmed'**
  String get idConfirmed;

  /// No description provided for @documentsApproved.
  ///
  /// In en, this message translates to:
  /// **'Documents Approved'**
  String get documentsApproved;

  /// No description provided for @documentsValid.
  ///
  /// In en, this message translates to:
  /// **'All documents are valid'**
  String get documentsValid;

  /// No description provided for @accountSecured.
  ///
  /// In en, this message translates to:
  /// **'Account Secured'**
  String get accountSecured;

  /// No description provided for @accountProtected.
  ///
  /// In en, this message translates to:
  /// **'Your account is protected'**
  String get accountProtected;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @whatYouCanDo.
  ///
  /// In en, this message translates to:
  /// **'What You Can Do Now'**
  String get whatYouCanDo;

  /// No description provided for @bookServices.
  ///
  /// In en, this message translates to:
  /// **'Book medical services'**
  String get bookServices;

  /// No description provided for @requestVisits.
  ///
  /// In en, this message translates to:
  /// **'Request home visits'**
  String get requestVisits;

  /// No description provided for @chatProviders.
  ///
  /// In en, this message translates to:
  /// **'Chat with healthcare providers'**
  String get chatProviders;

  /// No description provided for @accessHistory.
  ///
  /// In en, this message translates to:
  /// **'Access your medical history'**
  String get accessHistory;

  /// No description provided for @continueToLogin.
  ///
  /// In en, this message translates to:
  /// **'Continue to Login'**
  String get continueToLogin;

  /// No description provided for @medicalHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Medical History'**
  String get medicalHistoryTitle;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @stepInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get stepInfo;

  /// No description provided for @stepMedical.
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get stepMedical;

  /// No description provided for @stepId.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get stepId;

  /// No description provided for @healthInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Information'**
  String get healthInfoTitle;

  /// No description provided for @healthInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help us provide better care for you'**
  String get healthInfoSubtitle;

  /// No description provided for @healthInfoSafetyDesc.
  ///
  /// In en, this message translates to:
  /// **'This information helps our medical team prepare better for your visits and ensures your safety.'**
  String get healthInfoSafetyDesc;

  /// No description provided for @bloodTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Blood Type'**
  String get bloodTypeTitle;

  /// No description provided for @optionalLabel.
  ///
  /// In en, this message translates to:
  /// **'(Optional)'**
  String get optionalLabel;

  /// No description provided for @chronicDiseasesTitle.
  ///
  /// In en, this message translates to:
  /// **'Chronic Diseases'**
  String get chronicDiseasesTitle;

  /// No description provided for @noChronicDiseases.
  ///
  /// In en, this message translates to:
  /// **'I don\'t have any chronic diseases'**
  String get noChronicDiseases;

  /// No description provided for @allergiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergiesTitle;

  /// No description provided for @noAllergies.
  ///
  /// In en, this message translates to:
  /// **'I don\'t have any known allergies'**
  String get noAllergies;

  /// No description provided for @otherConditionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Other Medical Conditions'**
  String get otherConditionsTitle;

  /// No description provided for @otherConditionsHint.
  ///
  /// In en, this message translates to:
  /// **'Describe any other medical conditions...'**
  String get otherConditionsHint;

  /// No description provided for @currentMedicationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Current Medications'**
  String get currentMedicationsTitle;

  /// No description provided for @currentMedicationsHint.
  ///
  /// In en, this message translates to:
  /// **'List any medications you are currently taking...'**
  String get currentMedicationsHint;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @saveMedicalInfoError.
  ///
  /// In en, this message translates to:
  /// **'Could not save medical info. You can update it later.'**
  String get saveMedicalInfoError;

  /// No description provided for @diabetes.
  ///
  /// In en, this message translates to:
  /// **'Diabetes'**
  String get diabetes;

  /// No description provided for @highBloodPressure.
  ///
  /// In en, this message translates to:
  /// **'High Blood Pressure'**
  String get highBloodPressure;

  /// No description provided for @heartDisease.
  ///
  /// In en, this message translates to:
  /// **'Heart Disease'**
  String get heartDisease;

  /// No description provided for @asthma.
  ///
  /// In en, this message translates to:
  /// **'Asthma'**
  String get asthma;

  /// No description provided for @kidneyDisease.
  ///
  /// In en, this message translates to:
  /// **'Kidney Disease'**
  String get kidneyDisease;

  /// No description provided for @liverDisease.
  ///
  /// In en, this message translates to:
  /// **'Liver Disease'**
  String get liverDisease;

  /// No description provided for @cancer.
  ///
  /// In en, this message translates to:
  /// **'Cancer'**
  String get cancer;

  /// No description provided for @thyroidDisorder.
  ///
  /// In en, this message translates to:
  /// **'Thyroid Disorder'**
  String get thyroidDisorder;

  /// No description provided for @arthritis.
  ///
  /// In en, this message translates to:
  /// **'Arthritis'**
  String get arthritis;

  /// No description provided for @epilepsy.
  ///
  /// In en, this message translates to:
  /// **'Epilepsy'**
  String get epilepsy;

  /// No description provided for @penicillin.
  ///
  /// In en, this message translates to:
  /// **'Penicillin'**
  String get penicillin;

  /// No description provided for @sulfaDrugs.
  ///
  /// In en, this message translates to:
  /// **'Sulfa Drugs'**
  String get sulfaDrugs;

  /// No description provided for @aspirin.
  ///
  /// In en, this message translates to:
  /// **'Aspirin'**
  String get aspirin;

  /// No description provided for @ibuprofen.
  ///
  /// In en, this message translates to:
  /// **'Ibuprofen'**
  String get ibuprofen;

  /// No description provided for @latex.
  ///
  /// In en, this message translates to:
  /// **'Latex'**
  String get latex;

  /// No description provided for @peanuts.
  ///
  /// In en, this message translates to:
  /// **'Peanuts'**
  String get peanuts;

  /// No description provided for @shellfish.
  ///
  /// In en, this message translates to:
  /// **'Shellfish'**
  String get shellfish;

  /// No description provided for @eggs.
  ///
  /// In en, this message translates to:
  /// **'Eggs'**
  String get eggs;

  /// No description provided for @verifyIdentityTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Identity'**
  String get verifyIdentityTitle;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @verifyIdentityDesc.
  ///
  /// In en, this message translates to:
  /// **'As a licensed medical service, we need to verify your identity to ensure safety and trust for everyone.'**
  String get verifyIdentityDesc;

  /// No description provided for @securePrivateTitle.
  ///
  /// In en, this message translates to:
  /// **'Secure & Private'**
  String get securePrivateTitle;

  /// No description provided for @securePrivateDesc.
  ///
  /// In en, this message translates to:
  /// **'Your data is encrypted and protected'**
  String get securePrivateDesc;

  /// No description provided for @quickProcessTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Process'**
  String get quickProcessTitle;

  /// No description provided for @quickProcessDesc.
  ///
  /// In en, this message translates to:
  /// **'Verification takes less than 2 minutes'**
  String get quickProcessDesc;

  /// No description provided for @oneTimeOnlyTitle.
  ///
  /// In en, this message translates to:
  /// **'One-Time Only'**
  String get oneTimeOnlyTitle;

  /// No description provided for @oneTimeOnlyDesc.
  ///
  /// In en, this message translates to:
  /// **'Verify once, access all services'**
  String get oneTimeOnlyDesc;

  /// No description provided for @verifyNowButton.
  ///
  /// In en, this message translates to:
  /// **'Verify Now'**
  String get verifyNowButton;

  /// No description provided for @doItLater.
  ///
  /// In en, this message translates to:
  /// **'I\'ll do this later'**
  String get doItLater;

  /// No description provided for @idVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Identity Verification'**
  String get idVerificationTitle;

  /// No description provided for @scanFrontSide.
  ///
  /// In en, this message translates to:
  /// **'Scan Front Side'**
  String get scanFrontSide;

  /// No description provided for @scanBackSide.
  ///
  /// In en, this message translates to:
  /// **'Scan Back Side'**
  String get scanBackSide;

  /// No description provided for @stepXofY.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepXofY(Object current, Object total);

  /// No description provided for @frontLabel.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get frontLabel;

  /// No description provided for @backLabel.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backLabel;

  /// No description provided for @positionFrontId.
  ///
  /// In en, this message translates to:
  /// **'Position Front Side of ID'**
  String get positionFrontId;

  /// No description provided for @positionBackId.
  ///
  /// In en, this message translates to:
  /// **'Position Back Side of ID'**
  String get positionBackId;

  /// No description provided for @keepWithinFrame.
  ///
  /// In en, this message translates to:
  /// **'Keep the card within the frame'**
  String get keepWithinFrame;

  /// No description provided for @tipsForResults.
  ///
  /// In en, this message translates to:
  /// **'Tips for best results'**
  String get tipsForResults;

  /// No description provided for @goodLighting.
  ///
  /// In en, this message translates to:
  /// **'Ensure good lighting'**
  String get goodLighting;

  /// No description provided for @flatAligned.
  ///
  /// In en, this message translates to:
  /// **'Keep ID flat and aligned'**
  String get flatAligned;

  /// No description provided for @avoidBlur.
  ///
  /// In en, this message translates to:
  /// **'Avoid blur and reflections'**
  String get avoidBlur;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @uploadGallery.
  ///
  /// In en, this message translates to:
  /// **'Upload from Gallery'**
  String get uploadGallery;

  /// No description provided for @processingImage.
  ///
  /// In en, this message translates to:
  /// **'Processing Image...'**
  String get processingImage;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait'**
  String get pleaseWait;

  /// No description provided for @uploadingDocs.
  ///
  /// In en, this message translates to:
  /// **'Uploading Documents...'**
  String get uploadingDocs;

  /// No description provided for @securelySavingId.
  ///
  /// In en, this message translates to:
  /// **'Securely saving your ID'**
  String get securelySavingId;

  /// No description provided for @encryptedConnection.
  ///
  /// In en, this message translates to:
  /// **'End-to-end encrypted'**
  String get encryptedConnection;

  /// No description provided for @idPreview.
  ///
  /// In en, this message translates to:
  /// **'{side} ID Preview'**
  String idPreview(Object side);

  /// No description provided for @clearReadablePrompt.
  ///
  /// In en, this message translates to:
  /// **'Make sure all details are clear and readable'**
  String get clearReadablePrompt;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @frontSide.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get frontSide;

  /// No description provided for @backSide.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backSide;

  /// No description provided for @cameraError.
  ///
  /// In en, this message translates to:
  /// **'Failed to open camera'**
  String get cameraError;

  /// No description provided for @galleryError.
  ///
  /// In en, this message translates to:
  /// **'Failed to open gallery'**
  String get galleryError;

  /// No description provided for @noImageError.
  ///
  /// In en, this message translates to:
  /// **'No image selected'**
  String get noImageError;

  /// No description provided for @processImageError.
  ///
  /// In en, this message translates to:
  /// **'Failed to process image'**
  String get processImageError;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed: {error}'**
  String uploadFailed(Object error);

  /// No description provided for @docsSubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Documents Submitted!'**
  String get docsSubmittedTitle;

  /// No description provided for @docsSubmittedDesc.
  ///
  /// In en, this message translates to:
  /// **'Your ID has been sent for review.\nOur team will verify it shortly.'**
  String get docsSubmittedDesc;

  /// No description provided for @pendingAdminReview.
  ///
  /// In en, this message translates to:
  /// **'Pending Admin Review'**
  String get pendingAdminReview;

  /// No description provided for @takes24to48Hours.
  ///
  /// In en, this message translates to:
  /// **'Usually takes 24-48 hours'**
  String get takes24to48Hours;

  /// No description provided for @gotItContinue.
  ///
  /// In en, this message translates to:
  /// **'Got it, Continue'**
  String get gotItContinue;

  /// No description provided for @reviewNotice.
  ///
  /// In en, this message translates to:
  /// **'You can start using the app while we review'**
  String get reviewNotice;

  /// Label for the Home navigation item
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Label for the Bookings navigation item
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get navBookings;

  /// Label for the AI Assistant navigation item
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get navAI;

  /// Label for the Alerts navigation item
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get navAlerts;

  /// Label for the Profile navigation item
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Title shown when a visit is completed
  ///
  /// In en, this message translates to:
  /// **'Visit Completed'**
  String get visitCompletedTitle;

  /// Subtitle with the nurse name
  ///
  /// In en, this message translates to:
  /// **'Care by {nurseName}'**
  String visitCompletedSubtitle(Object nurseName);

  /// Title for the invoice summary card
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummaryTitle;

  /// Fallback label for the service name
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get serviceLabel;

  /// Label for destination fee line item
  ///
  /// In en, this message translates to:
  /// **'Destination Fee'**
  String get destinationFeeLabel;

  /// Label for platform fee line item
  ///
  /// In en, this message translates to:
  /// **'Platform Fee'**
  String get platformFeeLabel;

  /// Label for total amount
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// Title for the visit report section
  ///
  /// In en, this message translates to:
  /// **'Visit Report'**
  String get visitReportTitle;

  /// Title for rating section with nurse name
  ///
  /// In en, this message translates to:
  /// **'Rate {nurseName}'**
  String rateNurseTitle(Object nurseName);

  /// Title shown when rating is already submitted
  ///
  /// In en, this message translates to:
  /// **'Rating Submitted'**
  String get ratingSubmittedTitle;

  /// Prompt asking for rating feedback
  ///
  /// In en, this message translates to:
  /// **'How was the service provided?'**
  String get ratingPrompt;

  /// Message shown after rating is submitted
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get ratingThanks;

  /// Error shown when rating is not selected
  ///
  /// In en, this message translates to:
  /// **'Please select a rating'**
  String get ratingSelectError;

  /// Hint text for review input
  ///
  /// In en, this message translates to:
  /// **'Write a review (optional)...'**
  String get reviewHint;

  /// Button label to submit rating
  ///
  /// In en, this message translates to:
  /// **'Submit Rating'**
  String get submitRating;

  /// Loading label while submitting rating
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submitting;

  /// Snack bar message after rating submission
  ///
  /// In en, this message translates to:
  /// **'Thank you for rating!'**
  String get ratingThanksSnack;

  /// Message shown after rating is saved
  ///
  /// In en, this message translates to:
  /// **'Rating saved successfully!'**
  String get ratingSaved;

  /// CTA button text to return home
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// Currency label for Egyptian Pound
  ///
  /// In en, this message translates to:
  /// **'EGP'**
  String get currencyEgp;

  /// Fallback nurse name if missing
  ///
  /// In en, this message translates to:
  /// **'Nurse'**
  String get defaultNurseName;

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

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeBack;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'What do you need help with?'**
  String get searchPlaceholder;

  /// No description provided for @searchSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Search for clinics, nurses, or use AI Chatbot'**
  String get searchSemanticLabel;

  /// No description provided for @nursingService.
  ///
  /// In en, this message translates to:
  /// **'Nursing Service'**
  String get nursingService;

  /// No description provided for @assigningNurse.
  ///
  /// In en, this message translates to:
  /// **'Assigning...'**
  String get assigningNurse;

  /// No description provided for @activeStatus.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeStatus;

  /// No description provided for @housepitalWallet.
  ///
  /// In en, this message translates to:
  /// **'Housepital Wallet'**
  String get housepitalWallet;

  /// No description provided for @availableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get availableBalance;

  /// No description provided for @topUp.
  ///
  /// In en, this message translates to:
  /// **'Top Up'**
  String get topUp;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @bookNurse.
  ///
  /// In en, this message translates to:
  /// **'Book Nurse'**
  String get bookNurse;

  /// No description provided for @homeCare.
  ///
  /// In en, this message translates to:
  /// **'Home care'**
  String get homeCare;

  /// No description provided for @findClinic.
  ///
  /// In en, this message translates to:
  /// **'Find Clinic'**
  String get findClinic;

  /// No description provided for @bookVisits.
  ///
  /// In en, this message translates to:
  /// **'Book visits'**
  String get bookVisits;

  /// No description provided for @aiHealthAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Health Assistant'**
  String get aiHealthAssistant;

  /// No description provided for @newLabel.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get newLabel;

  /// No description provided for @aiAdviceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get instant health advice'**
  String get aiAdviceSubtitle;

  /// No description provided for @newsAndOffers.
  ///
  /// In en, this message translates to:
  /// **'News & Offers'**
  String get newsAndOffers;

  /// No description provided for @offer1Title.
  ///
  /// In en, this message translates to:
  /// **'20% off General Checkups'**
  String get offer1Title;

  /// No description provided for @offer1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Valid until end of month'**
  String get offer1Subtitle;

  /// No description provided for @offer2Title.
  ///
  /// In en, this message translates to:
  /// **'Free Dietitian Consult'**
  String get offer2Title;

  /// No description provided for @offer2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'With premium subscription'**
  String get offer2Subtitle;

  /// No description provided for @offer3Title.
  ///
  /// In en, this message translates to:
  /// **'Winter Flu Shots Available'**
  String get offer3Title;

  /// No description provided for @offer3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Book home visit now'**
  String get offer3Subtitle;

  /// No description provided for @offerDetailsSnack.
  ///
  /// In en, this message translates to:
  /// **'Offer: {title} - Details coming soon'**
  String offerDetailsSnack(Object title);

  /// No description provided for @dependents.
  ///
  /// In en, this message translates to:
  /// **'Family & Dependents'**
  String get dependents;

  /// No description provided for @dependentsDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage profiles for your family members'**
  String get dependentsDesc;

  /// No description provided for @securitySection.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securitySection;

  /// No description provided for @biometricLogin.
  ///
  /// In en, this message translates to:
  /// **'Biometric Login'**
  String get biometricLogin;

  /// No description provided for @biometricLoginDesc.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or face recognition to unlock'**
  String get biometricLoginDesc;

  /// No description provided for @biometricNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Biometrics not supported on this device'**
  String get biometricNotSupported;

  /// No description provided for @twoFactorAuth.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get twoFactorAuth;

  /// No description provided for @twoFactorAuthDesc.
  ///
  /// In en, this message translates to:
  /// **'Secure your account with an extra verification step'**
  String get twoFactorAuthDesc;

  /// No description provided for @loginActivity.
  ///
  /// In en, this message translates to:
  /// **'Login Activity'**
  String get loginActivity;

  /// No description provided for @loginActivityDesc.
  ///
  /// In en, this message translates to:
  /// **'Monitor active sessions and devices'**
  String get loginActivityDesc;

  /// No description provided for @notificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsSection;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @pushNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive real-time updates and alerts on your device'**
  String get pushNotificationsDesc;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotifications;

  /// No description provided for @emailNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Get summaries and receipts sent to your inbox'**
  String get emailNotificationsDesc;

  /// No description provided for @smsUpdates.
  ///
  /// In en, this message translates to:
  /// **'SMS Updates'**
  String get smsUpdates;

  /// No description provided for @smsUpdatesDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive appointment updates via text message'**
  String get smsUpdatesDesc;

  /// No description provided for @appearanceSection.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSection;

  /// No description provided for @dataSection.
  ///
  /// In en, this message translates to:
  /// **'Data & Privacy'**
  String get dataSection;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @clearCacheDesc.
  ///
  /// In en, this message translates to:
  /// **'Free up storage space by clearing cached files'**
  String get clearCacheDesc;

  /// No description provided for @clearCacheConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear the app cache? This will free up space but keep your personal settings.'**
  String get clearCacheConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully'**
  String get cacheCleared;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @clearAiHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear AI History'**
  String get clearAiHistory;

  /// No description provided for @clearAiHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your AI chatbot conversations'**
  String get clearAiHistoryDesc;

  /// No description provided for @clearAiHistoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear your conversation history with the AI Health Assistant? This action cannot be undone.'**
  String get clearAiHistoryConfirm;

  /// No description provided for @aiHistoryCleared.
  ///
  /// In en, this message translates to:
  /// **'AI history cleared successfully'**
  String get aiHistoryCleared;

  /// No description provided for @downloadMyData.
  ///
  /// In en, this message translates to:
  /// **'Download My Data'**
  String get downloadMyData;

  /// No description provided for @downloadMyDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Request a copy of your personal data'**
  String get downloadMyDataDesc;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @userLabel.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get userLabel;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out of your account?'**
  String get signOutConfirmDesc;

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// No description provided for @biometricConfirmIdentity.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to confirm identity'**
  String get biometricConfirmIdentity;

  /// No description provided for @biometricDisabled.
  ///
  /// In en, this message translates to:
  /// **'Biometric login disabled'**
  String get biometricDisabled;

  /// No description provided for @biometricEnabledSuccess.
  ///
  /// In en, this message translates to:
  /// **'Biometric login enabled successfully!'**
  String get biometricEnabledSuccess;

  /// No description provided for @biometricLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication is required to enable this feature'**
  String get biometricLoginRequired;

  /// No description provided for @myWallet.
  ///
  /// In en, this message translates to:
  /// **'My Wallet'**
  String get myWallet;

  /// No description provided for @myWalletDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage payments, cards, and transaction history'**
  String get myWalletDesc;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @personalInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'View and edit your personal profile details'**
  String get personalInfoDesc;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterNursing.
  ///
  /// In en, this message translates to:
  /// **'Nursing'**
  String get filterNursing;

  /// No description provided for @filterClinic.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get filterClinic;

  /// No description provided for @bookingsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get bookingsTitle;

  /// No description provided for @bookingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track and manage your appointments'**
  String get bookingsSubtitle;

  /// No description provided for @tabActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get tabActive;

  /// No description provided for @tabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tabHistory;

  /// No description provided for @familyTitle.
  ///
  /// In en, this message translates to:
  /// **'My Family'**
  String get familyTitle;

  /// No description provided for @addMember.
  ///
  /// In en, this message translates to:
  /// **'Add Member'**
  String get addMember;

  /// No description provided for @addFamilyMember.
  ///
  /// In en, this message translates to:
  /// **'Add Family Member'**
  String get addFamilyMember;

  /// No description provided for @aboutFamilyTitle.
  ///
  /// In en, this message translates to:
  /// **'About Family Members'**
  String get aboutFamilyTitle;

  /// No description provided for @aboutFamilyDesc.
  ///
  /// In en, this message translates to:
  /// **'Add family members to easily book nursing services for them. You can store their medical information for faster booking.'**
  String get aboutFamilyDesc;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get gotIt;

  /// No description provided for @loadingFamily.
  ///
  /// In en, this message translates to:
  /// **'Loading family members...'**
  String get loadingFamily;

  /// No description provided for @noFamilyMembers.
  ///
  /// In en, this message translates to:
  /// **'No Family Members Yet'**
  String get noFamilyMembers;

  /// No description provided for @noFamilyMembersDesc.
  ///
  /// In en, this message translates to:
  /// **'Add your loved ones to easily book nursing services for them'**
  String get noFamilyMembersDesc;

  /// No description provided for @errLoadFamily.
  ///
  /// In en, this message translates to:
  /// **'Unable to load family members. Please log in again.'**
  String get errLoadFamily;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// No description provided for @memberSingle.
  ///
  /// In en, this message translates to:
  /// **'1 member'**
  String get memberSingle;

  /// No description provided for @membersPlural.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String membersPlural(Object count);

  /// No description provided for @editFamilyMember.
  ///
  /// In en, this message translates to:
  /// **'Edit Family Member'**
  String get editFamilyMember;

  /// No description provided for @deleteMember.
  ///
  /// In en, this message translates to:
  /// **'Delete Member'**
  String get deleteMember;

  /// No description provided for @deleteMemberConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?'**
  String deleteMemberConfirm(Object name);

  /// No description provided for @actionUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone'**
  String get actionUndone;

  /// No description provided for @discardChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard Changes?'**
  String get discardChangesTitle;

  /// No description provided for @discardChangesDesc.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Are you sure you want to leave without saving?'**
  String get discardChangesDesc;

  /// No description provided for @keepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep Editing'**
  String get keepEditing;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @changesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes Saved!'**
  String get changesSaved;

  /// No description provided for @familyMemberUpdated.
  ///
  /// In en, this message translates to:
  /// **'Family member information has been updated successfully.'**
  String get familyMemberUpdated;

  /// No description provided for @relationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get relationship;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @nationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get nationalId;

  /// No description provided for @birthCertificateId.
  ///
  /// In en, this message translates to:
  /// **'Birth Certificate ID'**
  String get birthCertificateId;

  /// No description provided for @chronicConditions.
  ///
  /// In en, this message translates to:
  /// **'Chronic Conditions'**
  String get chronicConditions;

  /// No description provided for @allergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergies;

  /// No description provided for @addChronicCondition.
  ///
  /// In en, this message translates to:
  /// **'Add Chronic Disease'**
  String get addChronicCondition;

  /// No description provided for @addAllergy.
  ///
  /// In en, this message translates to:
  /// **'Add Allergy'**
  String get addAllergy;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @relationshipFather.
  ///
  /// In en, this message translates to:
  /// **'Father'**
  String get relationshipFather;

  /// No description provided for @relationshipMother.
  ///
  /// In en, this message translates to:
  /// **'Mother'**
  String get relationshipMother;

  /// No description provided for @relationshipSon.
  ///
  /// In en, this message translates to:
  /// **'Son'**
  String get relationshipSon;

  /// No description provided for @relationshipDaughter.
  ///
  /// In en, this message translates to:
  /// **'Daughter'**
  String get relationshipDaughter;

  /// No description provided for @relationshipBrother.
  ///
  /// In en, this message translates to:
  /// **'Brother'**
  String get relationshipBrother;

  /// No description provided for @relationshipSister.
  ///
  /// In en, this message translates to:
  /// **'Sister'**
  String get relationshipSister;

  /// No description provided for @relationshipGrandparent.
  ///
  /// In en, this message translates to:
  /// **'Grandparent'**
  String get relationshipGrandparent;

  /// No description provided for @relationshipGrandchild.
  ///
  /// In en, this message translates to:
  /// **'Grandchild'**
  String get relationshipGrandchild;

  /// No description provided for @relationshipSpouse.
  ///
  /// In en, this message translates to:
  /// **'Spouse'**
  String get relationshipSpouse;

  /// No description provided for @relationshipOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get relationshipOther;

  /// No description provided for @savedAddressesTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved Addresses'**
  String get savedAddressesTitle;

  /// No description provided for @addressSavedSingle.
  ///
  /// In en, this message translates to:
  /// **'1 Address Saved'**
  String get addressSavedSingle;

  /// No description provided for @addressesSavedPlural.
  ///
  /// In en, this message translates to:
  /// **'{count} Addresses Saved'**
  String addressesSavedPlural(Object count);

  /// No description provided for @manageLocations.
  ///
  /// In en, this message translates to:
  /// **'Manage your delivery locations'**
  String get manageLocations;

  /// No description provided for @loadingAddresses.
  ///
  /// In en, this message translates to:
  /// **'Loading addresses...'**
  String get loadingAddresses;

  /// No description provided for @noSavedAddresses.
  ///
  /// In en, this message translates to:
  /// **'No Saved Addresses'**
  String get noSavedAddresses;

  /// No description provided for @noSavedAddressesDesc.
  ///
  /// In en, this message translates to:
  /// **'Add your first address to get started with home nursing services'**
  String get noSavedAddressesDesc;

  /// No description provided for @addFirstAddress.
  ///
  /// In en, this message translates to:
  /// **'Add Your First Address'**
  String get addFirstAddress;

  /// No description provided for @addAddress.
  ///
  /// In en, this message translates to:
  /// **'Add Address'**
  String get addAddress;

  /// No description provided for @aboutAddresses.
  ///
  /// In en, this message translates to:
  /// **'About Addresses'**
  String get aboutAddresses;

  /// No description provided for @addressTypeHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get addressTypeHome;

  /// No description provided for @addressTypeWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get addressTypeWork;

  /// No description provided for @addressTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get addressTypeOther;

  /// No description provided for @addressTypeHomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Your primary residence'**
  String get addressTypeHomeDesc;

  /// No description provided for @addressTypeWorkDesc.
  ///
  /// In en, this message translates to:
  /// **'Your workplace address'**
  String get addressTypeWorkDesc;

  /// No description provided for @addressTypeOtherDesc.
  ///
  /// In en, this message translates to:
  /// **'Any other location'**
  String get addressTypeOtherDesc;

  /// No description provided for @defaultAddressNote.
  ///
  /// In en, this message translates to:
  /// **'Set a default address for faster booking'**
  String get defaultAddressNote;

  /// No description provided for @defaultTag.
  ///
  /// In en, this message translates to:
  /// **'DEFAULT'**
  String get defaultTag;

  /// No description provided for @addressOptions.
  ///
  /// In en, this message translates to:
  /// **'Address Options'**
  String get addressOptions;

  /// No description provided for @setAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as Default'**
  String get setAsDefault;

  /// No description provided for @editAddress.
  ///
  /// In en, this message translates to:
  /// **'Edit Address'**
  String get editAddress;

  /// No description provided for @deleteAddress.
  ///
  /// In en, this message translates to:
  /// **'Delete Address'**
  String get deleteAddress;

  /// No description provided for @confirmDeleteAddress.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this address?'**
  String get confirmDeleteAddress;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @addressDeleted.
  ///
  /// In en, this message translates to:
  /// **'Address deleted successfully'**
  String get addressDeleted;

  /// No description provided for @addressSetDefault.
  ///
  /// In en, this message translates to:
  /// **'Address set as default successfully'**
  String get addressSetDefault;

  /// No description provided for @errSetDefault.
  ///
  /// In en, this message translates to:
  /// **'Failed to set default address'**
  String get errSetDefault;

  /// No description provided for @errDeleteAddress.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete address'**
  String get errDeleteAddress;

  /// No description provided for @errLoadAddresses.
  ///
  /// In en, this message translates to:
  /// **'Unable to load addresses. Please log in again.'**
  String get errLoadAddresses;

  /// No description provided for @mapLocation.
  ///
  /// In en, this message translates to:
  /// **'Map Location'**
  String get mapLocation;

  /// No description provided for @locationNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Location not selected'**
  String get locationNotSelected;

  /// No description provided for @locationSelected.
  ///
  /// In en, this message translates to:
  /// **'Location selected'**
  String get locationSelected;

  /// No description provided for @requiredForTracking.
  ///
  /// In en, this message translates to:
  /// **'Required for nurse tracking'**
  String get requiredForTracking;

  /// No description provided for @pick.
  ///
  /// In en, this message translates to:
  /// **'Pick'**
  String get pick;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @addressDetails.
  ///
  /// In en, this message translates to:
  /// **'Address Details'**
  String get addressDetails;

  /// No description provided for @labelOptional.
  ///
  /// In en, this message translates to:
  /// **'Label (Optional)'**
  String get labelOptional;

  /// No description provided for @labelHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Home, Office, Mom\'s Place'**
  String get labelHint;

  /// No description provided for @streetAddress.
  ///
  /// In en, this message translates to:
  /// **'Street Address'**
  String get streetAddress;

  /// No description provided for @enterStreet.
  ///
  /// In en, this message translates to:
  /// **'Enter street address'**
  String get enterStreet;

  /// No description provided for @areaDistrict.
  ///
  /// In en, this message translates to:
  /// **'Area / District'**
  String get areaDistrict;

  /// No description provided for @enterArea.
  ///
  /// In en, this message translates to:
  /// **'Enter area or district'**
  String get enterArea;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @enterCity.
  ///
  /// In en, this message translates to:
  /// **'Enter city'**
  String get enterCity;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @enterState.
  ///
  /// In en, this message translates to:
  /// **'Enter state'**
  String get enterState;

  /// No description provided for @zipCode.
  ///
  /// In en, this message translates to:
  /// **'Zip / Postal Code'**
  String get zipCode;

  /// No description provided for @enterZip.
  ///
  /// In en, this message translates to:
  /// **'Enter zip code'**
  String get enterZip;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @setDefaultAddress.
  ///
  /// In en, this message translates to:
  /// **'Set as default address'**
  String get setDefaultAddress;

  /// No description provided for @setDefaultAddressDesc.
  ///
  /// In en, this message translates to:
  /// **'Use this address by default for bookings'**
  String get setDefaultAddressDesc;

  /// No description provided for @updateAddress.
  ///
  /// In en, this message translates to:
  /// **'Update Address'**
  String get updateAddress;

  /// No description provided for @addressUpdated.
  ///
  /// In en, this message translates to:
  /// **'Address Updated!'**
  String get addressUpdated;

  /// No description provided for @addressUpdatedDesc.
  ///
  /// In en, this message translates to:
  /// **'Your address has been updated successfully.'**
  String get addressUpdatedDesc;

  /// No description provided for @pinLocationFirst.
  ///
  /// In en, this message translates to:
  /// **'Please pin your location on the map first.'**
  String get pinLocationFirst;

  /// No description provided for @errLoadUserId.
  ///
  /// In en, this message translates to:
  /// **'User ID not found. Please log in again.'**
  String get errLoadUserId;

  /// No description provided for @errUpdateAddress.
  ///
  /// In en, this message translates to:
  /// **'Failed to update address'**
  String get errUpdateAddress;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @warningUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone'**
  String get warningUndone;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @mobileNumberOptional.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number (Optional)'**
  String get mobileNumberOptional;

  /// No description provided for @identification.
  ///
  /// In en, this message translates to:
  /// **'Identification'**
  String get identification;

  /// No description provided for @provideOneId.
  ///
  /// In en, this message translates to:
  /// **'Provide at least one ID'**
  String get provideOneId;

  /// No description provided for @medicalInformation.
  ///
  /// In en, this message translates to:
  /// **'Medical Information'**
  String get medicalInformation;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @deleteFamilyMemberDesc.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete this family member from your account. This action cannot be undone.'**
  String get deleteFamilyMemberDesc;

  /// No description provided for @noChanges.
  ///
  /// In en, this message translates to:
  /// **'No Changes'**
  String get noChanges;

  /// No description provided for @noItemsAdded.
  ///
  /// In en, this message translates to:
  /// **'No {title} added'**
  String noItemsAdded(Object title);

  /// No description provided for @addChronicDiseaseHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Diabetes, Hypertension'**
  String get addChronicDiseaseHint;

  /// No description provided for @addAllergyHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Penicillin, Peanuts'**
  String get addAllergyHint;

  /// No description provided for @selectRelationshipWarn.
  ///
  /// In en, this message translates to:
  /// **'Please select a relationship'**
  String get selectRelationshipWarn;

  /// No description provided for @selectDobWarn.
  ///
  /// In en, this message translates to:
  /// **'Please select date of birth'**
  String get selectDobWarn;

  /// No description provided for @provideIdWarn.
  ///
  /// In en, this message translates to:
  /// **'Please provide either National ID or Birth Certificate ID'**
  String get provideIdWarn;

  /// No description provided for @deleteMemberSuccess.
  ///
  /// In en, this message translates to:
  /// **'Family member deleted successfully'**
  String get deleteMemberSuccess;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @modified.
  ///
  /// In en, this message translates to:
  /// **'Modified'**
  String get modified;

  /// No description provided for @deleteFamilyMember.
  ///
  /// In en, this message translates to:
  /// **'Delete Family Member'**
  String get deleteFamilyMember;

  /// No description provided for @addressType.
  ///
  /// In en, this message translates to:
  /// **'Address Type'**
  String get addressType;

  /// No description provided for @loadingBookings.
  ///
  /// In en, this message translates to:
  /// **'Loading bookings...'**
  String get loadingBookings;

  /// No description provided for @noActiveBookings.
  ///
  /// In en, this message translates to:
  /// **'No Active Bookings'**
  String get noActiveBookings;

  /// No description provided for @noActiveBookingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Your upcoming appointments will appear here'**
  String get noActiveBookingsDesc;

  /// No description provided for @noBookingHistory.
  ///
  /// In en, this message translates to:
  /// **'No Booking History'**
  String get noBookingHistory;

  /// No description provided for @noBookingHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Your completed bookings will appear here'**
  String get noBookingHistoryDesc;

  /// No description provided for @bookService.
  ///
  /// In en, this message translates to:
  /// **'Book a Service'**
  String get bookService;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @inClinic.
  ///
  /// In en, this message translates to:
  /// **'In Clinic'**
  String get inClinic;

  /// No description provided for @nurseArrived.
  ///
  /// In en, this message translates to:
  /// **'Nurse Arrived'**
  String get nurseArrived;

  /// No description provided for @readyForVisit.
  ///
  /// In en, this message translates to:
  /// **'Ready For Visit'**
  String get readyForVisit;

  /// No description provided for @onTheWay.
  ///
  /// In en, this message translates to:
  /// **'On The Way'**
  String get onTheWay;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @awaitingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Awaiting Confirmation'**
  String get awaitingConfirmation;

  /// No description provided for @findingNurse.
  ///
  /// In en, this message translates to:
  /// **'Finding Nurse'**
  String get findingNurse;

  /// No description provided for @nurseOffersReady.
  ///
  /// In en, this message translates to:
  /// **'Nurse Offers Ready'**
  String get nurseOffersReady;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @viewTicket.
  ///
  /// In en, this message translates to:
  /// **'View Ticket'**
  String get viewTicket;

  /// No description provided for @track.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get track;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusNoShow.
  ///
  /// In en, this message translates to:
  /// **'No Show'**
  String get statusNoShow;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @rebook.
  ///
  /// In en, this message translates to:
  /// **'Rebook'**
  String get rebook;

  /// No description provided for @nurseLabel.
  ///
  /// In en, this message translates to:
  /// **'Nurse'**
  String get nurseLabel;

  /// No description provided for @cancelBookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking?'**
  String get cancelBookingTitle;

  /// No description provided for @cancelBookingLateDesc.
  ///
  /// In en, this message translates to:
  /// **'Since the nurse is already assigned, a late cancellation fee of {fee} EGP will apply.'**
  String cancelBookingLateDesc(Object fee);

  /// No description provided for @cancelBookingNormalDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this booking? This action cannot be undone.'**
  String get cancelBookingNormalDesc;

  /// No description provided for @lateCancellationFee.
  ///
  /// In en, this message translates to:
  /// **'Late Cancellation Fee: {fee} EGP'**
  String lateCancellationFee(Object fee);

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @cancelAndPayFee.
  ///
  /// In en, this message translates to:
  /// **'Cancel & Pay Fee'**
  String get cancelAndPayFee;

  /// No description provided for @yesCancel.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get yesCancel;

  /// No description provided for @bookingCancelled.
  ///
  /// In en, this message translates to:
  /// **'Booking cancelled'**
  String get bookingCancelled;

  /// No description provided for @matchingRequestCancelled.
  ///
  /// In en, this message translates to:
  /// **'Matching request cancelled'**
  String get matchingRequestCancelled;

  /// No description provided for @failedToCancelMatching.
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel matching request'**
  String get failedToCancelMatching;

  /// No description provided for @queueLabel.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get queueLabel;

  /// No description provided for @digitalTicket.
  ///
  /// In en, this message translates to:
  /// **'Digital Ticket'**
  String get digitalTicket;

  /// No description provided for @scanAtReception.
  ///
  /// In en, this message translates to:
  /// **'Scan at reception'**
  String get scanAtReception;

  /// No description provided for @checkInPin.
  ///
  /// In en, this message translates to:
  /// **'Check-in PIN'**
  String get checkInPin;

  /// No description provided for @patientLabel.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patientLabel;

  /// No description provided for @clinicLabel.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get clinicLabel;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @doctorLabel.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctorLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @ticketInstruction.
  ///
  /// In en, this message translates to:
  /// **'Show this QR code or PIN at the clinic reception to check in.'**
  String get ticketInstruction;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @estArrival.
  ///
  /// In en, this message translates to:
  /// **'Est. arrival'**
  String get estArrival;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @youLabel.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get youLabel;

  /// No description provided for @visitStartCode.
  ///
  /// In en, this message translates to:
  /// **'VISIT START CODE'**
  String get visitStartCode;

  /// No description provided for @provideStartCodeDesc.
  ///
  /// In en, this message translates to:
  /// **'Provide this to the nurse to begin the session.'**
  String get provideStartCodeDesc;

  /// No description provided for @serviceInProgress.
  ///
  /// In en, this message translates to:
  /// **'Service in Progress'**
  String get serviceInProgress;

  /// No description provided for @serviceInProgressDesc.
  ///
  /// In en, this message translates to:
  /// **'The nurse is providing {serviceName}. The visit will be marked complete soon.'**
  String serviceInProgressDesc(Object serviceName);

  /// No description provided for @newTag.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newTag;

  /// No description provided for @registeredNurse.
  ///
  /// In en, this message translates to:
  /// **'Registered Nurse'**
  String get registeredNurse;

  /// No description provided for @callingNurse.
  ///
  /// In en, this message translates to:
  /// **'Calling {phone}...'**
  String callingNurse(Object phone);

  /// No description provided for @callingEmergency.
  ///
  /// In en, this message translates to:
  /// **'Calling Emergency Services...'**
  String get callingEmergency;

  /// No description provided for @sosLabel.
  ///
  /// In en, this message translates to:
  /// **'SOS'**
  String get sosLabel;

  /// No description provided for @filingReport.
  ///
  /// In en, this message translates to:
  /// **'Filing a report...'**
  String get filingReport;

  /// No description provided for @reportLabel.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportLabel;

  /// No description provided for @nurseAssigned.
  ///
  /// In en, this message translates to:
  /// **'Nurse Assigned'**
  String get nurseAssigned;

  /// No description provided for @nurseOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'Nurse On The Way'**
  String get nurseOnTheWay;

  /// No description provided for @nurseHasArrived.
  ///
  /// In en, this message translates to:
  /// **'Nurse Has Arrived'**
  String get nurseHasArrived;

  /// No description provided for @serviceInProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Service In Progress'**
  String get serviceInProgressLabel;

  /// No description provided for @waitingNurseDesc.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the nurse to head to your location.'**
  String get waitingNurseDesc;

  /// No description provided for @nurseHeadingDesc.
  ///
  /// In en, this message translates to:
  /// **'The nurse is heading to your location right now.'**
  String get nurseHeadingDesc;

  /// No description provided for @nurseOutsideDesc.
  ///
  /// In en, this message translates to:
  /// **'Nurse is outside. Please provide the START CODE.'**
  String get nurseOutsideDesc;

  /// No description provided for @nurseProvidingDesc.
  ///
  /// In en, this message translates to:
  /// **'The nurse is currently providing the service.'**
  String get nurseProvidingDesc;

  /// No description provided for @trackingDesc.
  ///
  /// In en, this message translates to:
  /// **'We are tracking your appointment.'**
  String get trackingDesc;

  /// No description provided for @trackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get trackingTitle;

  /// No description provided for @unitMinutes.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get unitMinutes;

  /// No description provided for @unitHours.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get unitHours;

  /// No description provided for @unitMeters.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get unitMeters;

  /// No description provided for @unitKilometers.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get unitKilometers;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get categoryPopular;

  /// No description provided for @categoryQuick.
  ///
  /// In en, this message translates to:
  /// **'Quick'**
  String get categoryQuick;

  /// No description provided for @categorySpecialized.
  ///
  /// In en, this message translates to:
  /// **'Specialized'**
  String get categorySpecialized;

  /// No description provided for @categoryLongTerm.
  ///
  /// In en, this message translates to:
  /// **'Long-term'**
  String get categoryLongTerm;

  /// No description provided for @serviceWoundCareTitle.
  ///
  /// In en, this message translates to:
  /// **'Wound Care'**
  String get serviceWoundCareTitle;

  /// No description provided for @serviceWoundCareDuration.
  ///
  /// In en, this message translates to:
  /// **'30-45 min'**
  String get serviceWoundCareDuration;

  /// No description provided for @serviceWoundCareDesc.
  ///
  /// In en, this message translates to:
  /// **'Professional wound care and dressing services provided by certified nurses.'**
  String get serviceWoundCareDesc;

  /// No description provided for @serviceWoundCareInc1.
  ///
  /// In en, this message translates to:
  /// **'Professional wound assessment'**
  String get serviceWoundCareInc1;

  /// No description provided for @serviceWoundCareInc2.
  ///
  /// In en, this message translates to:
  /// **'Sterile dressing'**
  String get serviceWoundCareInc2;

  /// No description provided for @serviceWoundCareInc3.
  ///
  /// In en, this message translates to:
  /// **'Wound cleaning'**
  String get serviceWoundCareInc3;

  /// No description provided for @serviceWoundCareInc4.
  ///
  /// In en, this message translates to:
  /// **'Follow-up visits'**
  String get serviceWoundCareInc4;

  /// No description provided for @serviceWoundCareInc5.
  ///
  /// In en, this message translates to:
  /// **'Progress monitoring'**
  String get serviceWoundCareInc5;

  /// No description provided for @serviceInjectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Injections'**
  String get serviceInjectionsTitle;

  /// No description provided for @serviceInjectionsDuration.
  ///
  /// In en, this message translates to:
  /// **'15-20 min'**
  String get serviceInjectionsDuration;

  /// No description provided for @serviceInjectionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Safe and painless injection services at your home.'**
  String get serviceInjectionsDesc;

  /// No description provided for @serviceInjectionsInc1.
  ///
  /// In en, this message translates to:
  /// **'All types of injections'**
  String get serviceInjectionsInc1;

  /// No description provided for @serviceInjectionsInc2.
  ///
  /// In en, this message translates to:
  /// **'Proper sterilization'**
  String get serviceInjectionsInc2;

  /// No description provided for @serviceInjectionsInc3.
  ///
  /// In en, this message translates to:
  /// **'Medication administration'**
  String get serviceInjectionsInc3;

  /// No description provided for @serviceInjectionsInc4.
  ///
  /// In en, this message translates to:
  /// **'Post-injection care'**
  String get serviceInjectionsInc4;

  /// No description provided for @serviceElderlyCareTitle.
  ///
  /// In en, this message translates to:
  /// **'Elderly Care'**
  String get serviceElderlyCareTitle;

  /// No description provided for @serviceElderlyCareDuration.
  ///
  /// In en, this message translates to:
  /// **'1-4 hours'**
  String get serviceElderlyCareDuration;

  /// No description provided for @serviceElderlyCareDesc.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive care for elderly patients including assistance with daily activities.'**
  String get serviceElderlyCareDesc;

  /// No description provided for @serviceElderlyCareInc1.
  ///
  /// In en, this message translates to:
  /// **'Daily activity assistance'**
  String get serviceElderlyCareInc1;

  /// No description provided for @serviceElderlyCareInc2.
  ///
  /// In en, this message translates to:
  /// **'Medication management'**
  String get serviceElderlyCareInc2;

  /// No description provided for @serviceElderlyCareInc3.
  ///
  /// In en, this message translates to:
  /// **'Vital signs monitoring'**
  String get serviceElderlyCareInc3;

  /// No description provided for @serviceElderlyCareInc4.
  ///
  /// In en, this message translates to:
  /// **'Companionship'**
  String get serviceElderlyCareInc4;

  /// No description provided for @servicePostOpCareTitle.
  ///
  /// In en, this message translates to:
  /// **'Post-Op Care'**
  String get servicePostOpCareTitle;

  /// No description provided for @servicePostOpCareDuration.
  ///
  /// In en, this message translates to:
  /// **'45-60 min'**
  String get servicePostOpCareDuration;

  /// No description provided for @servicePostOpCareDesc.
  ///
  /// In en, this message translates to:
  /// **'Post-operative care services to ensure smooth recovery after surgery.'**
  String get servicePostOpCareDesc;

  /// No description provided for @servicePostOpCareInc1.
  ///
  /// In en, this message translates to:
  /// **'Surgical wound care'**
  String get servicePostOpCareInc1;

  /// No description provided for @servicePostOpCareInc2.
  ///
  /// In en, this message translates to:
  /// **'Pain management'**
  String get servicePostOpCareInc2;

  /// No description provided for @servicePostOpCareInc3.
  ///
  /// In en, this message translates to:
  /// **'Medication administration'**
  String get servicePostOpCareInc3;

  /// No description provided for @servicePostOpCareInc4.
  ///
  /// In en, this message translates to:
  /// **'Vital signs monitoring'**
  String get servicePostOpCareInc4;

  /// No description provided for @serviceBabyCareTitle.
  ///
  /// In en, this message translates to:
  /// **'Baby Care'**
  String get serviceBabyCareTitle;

  /// No description provided for @serviceBabyCareDuration.
  ///
  /// In en, this message translates to:
  /// **'2-3 hours'**
  String get serviceBabyCareDuration;

  /// No description provided for @serviceBabyCareDesc.
  ///
  /// In en, this message translates to:
  /// **'Professional newborn and infant care services.'**
  String get serviceBabyCareDesc;

  /// No description provided for @serviceBabyCareInc1.
  ///
  /// In en, this message translates to:
  /// **'Newborn monitoring'**
  String get serviceBabyCareInc1;

  /// No description provided for @serviceBabyCareInc2.
  ///
  /// In en, this message translates to:
  /// **'Feeding assistance'**
  String get serviceBabyCareInc2;

  /// No description provided for @serviceBabyCareInc3.
  ///
  /// In en, this message translates to:
  /// **'Bathing'**
  String get serviceBabyCareInc3;

  /// No description provided for @serviceBabyCareInc4.
  ///
  /// In en, this message translates to:
  /// **'Development assessment'**
  String get serviceBabyCareInc4;

  /// No description provided for @serviceIvTherapyTitle.
  ///
  /// In en, this message translates to:
  /// **'IV Therapy'**
  String get serviceIvTherapyTitle;

  /// No description provided for @serviceIvTherapyDuration.
  ///
  /// In en, this message translates to:
  /// **'45-60 min'**
  String get serviceIvTherapyDuration;

  /// No description provided for @serviceIvTherapyDesc.
  ///
  /// In en, this message translates to:
  /// **'Intravenous fluid and medication administration'**
  String get serviceIvTherapyDesc;

  /// No description provided for @serviceIvTherapyInc1.
  ///
  /// In en, this message translates to:
  /// **'IV line insertion'**
  String get serviceIvTherapyInc1;

  /// No description provided for @serviceIvTherapyInc2.
  ///
  /// In en, this message translates to:
  /// **'Medication administration'**
  String get serviceIvTherapyInc2;

  /// No description provided for @serviceIvTherapyInc3.
  ///
  /// In en, this message translates to:
  /// **'Fluid therapy'**
  String get serviceIvTherapyInc3;

  /// No description provided for @serviceIvTherapyInc4.
  ///
  /// In en, this message translates to:
  /// **'Monitoring'**
  String get serviceIvTherapyInc4;

  /// No description provided for @serviceCatheterCareTitle.
  ///
  /// In en, this message translates to:
  /// **'Catheter Care'**
  String get serviceCatheterCareTitle;

  /// No description provided for @serviceCatheterCareDuration.
  ///
  /// In en, this message translates to:
  /// **'30-40 min'**
  String get serviceCatheterCareDuration;

  /// No description provided for @serviceCatheterCareDesc.
  ///
  /// In en, this message translates to:
  /// **'Professional catheter insertion, maintenance, and care services.'**
  String get serviceCatheterCareDesc;

  /// No description provided for @serviceCatheterCareInc1.
  ///
  /// In en, this message translates to:
  /// **'Catheter insertion'**
  String get serviceCatheterCareInc1;

  /// No description provided for @serviceCatheterCareInc2.
  ///
  /// In en, this message translates to:
  /// **'Regular maintenance'**
  String get serviceCatheterCareInc2;

  /// No description provided for @serviceCatheterCareInc3.
  ///
  /// In en, this message translates to:
  /// **'Infection prevention'**
  String get serviceCatheterCareInc3;

  /// No description provided for @serviceCatheterCareInc4.
  ///
  /// In en, this message translates to:
  /// **'Patient education'**
  String get serviceCatheterCareInc4;

  /// No description provided for @serviceVitalSignsTitle.
  ///
  /// In en, this message translates to:
  /// **'Vital Signs'**
  String get serviceVitalSignsTitle;

  /// No description provided for @serviceVitalSignsDuration.
  ///
  /// In en, this message translates to:
  /// **'20-30 min'**
  String get serviceVitalSignsDuration;

  /// No description provided for @serviceVitalSignsDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete vital signs monitoring with detailed reporting.'**
  String get serviceVitalSignsDesc;

  /// No description provided for @serviceVitalSignsInc1.
  ///
  /// In en, this message translates to:
  /// **'Blood pressure'**
  String get serviceVitalSignsInc1;

  /// No description provided for @serviceVitalSignsInc2.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get serviceVitalSignsInc2;

  /// No description provided for @serviceVitalSignsInc3.
  ///
  /// In en, this message translates to:
  /// **'Heart rate'**
  String get serviceVitalSignsInc3;

  /// No description provided for @serviceVitalSignsInc4.
  ///
  /// In en, this message translates to:
  /// **'Oxygen saturation'**
  String get serviceVitalSignsInc4;

  /// No description provided for @serviceVitalSignsInc5.
  ///
  /// In en, this message translates to:
  /// **'Health report'**
  String get serviceVitalSignsInc5;

  /// No description provided for @serviceBloodDrawTitle.
  ///
  /// In en, this message translates to:
  /// **'Blood Draw'**
  String get serviceBloodDrawTitle;

  /// No description provided for @serviceBloodDrawDuration.
  ///
  /// In en, this message translates to:
  /// **'15 min'**
  String get serviceBloodDrawDuration;

  /// No description provided for @serviceBloodDrawDesc.
  ///
  /// In en, this message translates to:
  /// **'Professional blood sample collection at your home.'**
  String get serviceBloodDrawDesc;

  /// No description provided for @serviceBloodDrawInc1.
  ///
  /// In en, this message translates to:
  /// **'Blood sample collection'**
  String get serviceBloodDrawInc1;

  /// No description provided for @serviceBloodDrawInc2.
  ///
  /// In en, this message translates to:
  /// **'Proper labeling'**
  String get serviceBloodDrawInc2;

  /// No description provided for @serviceBloodDrawInc3.
  ///
  /// In en, this message translates to:
  /// **'Lab delivery'**
  String get serviceBloodDrawInc3;

  /// No description provided for @serviceBloodDrawInc4.
  ///
  /// In en, this message translates to:
  /// **'Results coordination'**
  String get serviceBloodDrawInc4;

  /// No description provided for @servicePhysiotherapyTitle.
  ///
  /// In en, this message translates to:
  /// **'Physiotherapy'**
  String get servicePhysiotherapyTitle;

  /// No description provided for @servicePhysiotherapyDuration.
  ///
  /// In en, this message translates to:
  /// **'60-90 min'**
  String get servicePhysiotherapyDuration;

  /// No description provided for @servicePhysiotherapyDesc.
  ///
  /// In en, this message translates to:
  /// **'Home physiotherapy sessions for rehabilitation and mobility.'**
  String get servicePhysiotherapyDesc;

  /// No description provided for @servicePhysiotherapyInc1.
  ///
  /// In en, this message translates to:
  /// **'Assessment'**
  String get servicePhysiotherapyInc1;

  /// No description provided for @servicePhysiotherapyInc2.
  ///
  /// In en, this message translates to:
  /// **'Exercise therapy'**
  String get servicePhysiotherapyInc2;

  /// No description provided for @servicePhysiotherapyInc3.
  ///
  /// In en, this message translates to:
  /// **'Mobility training'**
  String get servicePhysiotherapyInc3;

  /// No description provided for @servicePhysiotherapyInc4.
  ///
  /// In en, this message translates to:
  /// **'Progress tracking'**
  String get servicePhysiotherapyInc4;

  /// No description provided for @categoryAllServices.
  ///
  /// In en, this message translates to:
  /// **'All Services'**
  String get categoryAllServices;

  /// No description provided for @categoryPostSurgery.
  ///
  /// In en, this message translates to:
  /// **'Post-Surgery'**
  String get categoryPostSurgery;

  /// No description provided for @categoryElderlyCare.
  ///
  /// In en, this message translates to:
  /// **'Elderly Care'**
  String get categoryElderlyCare;

  /// No description provided for @categoryInjections.
  ///
  /// In en, this message translates to:
  /// **'Injections'**
  String get categoryInjections;

  /// No description provided for @categoryWoundCare.
  ///
  /// In en, this message translates to:
  /// **'Wound Care'**
  String get categoryWoundCare;

  /// No description provided for @categoryOrthopedic.
  ///
  /// In en, this message translates to:
  /// **'Orthopedic'**
  String get categoryOrthopedic;

  /// No description provided for @servicePostSurgicalCareTitle.
  ///
  /// In en, this message translates to:
  /// **'Post-Surgical Care'**
  String get servicePostSurgicalCareTitle;

  /// No description provided for @servicePostSurgicalCareDesc.
  ///
  /// In en, this message translates to:
  /// **'Professional nursing care for patients recovering from surgery'**
  String get servicePostSurgicalCareDesc;

  /// No description provided for @servicePostSurgicalCareDuration.
  ///
  /// In en, this message translates to:
  /// **'2-3 hours'**
  String get servicePostSurgicalCareDuration;

  /// No description provided for @servicePostSurgicalCareInc1.
  ///
  /// In en, this message translates to:
  /// **'Wound dressing and care'**
  String get servicePostSurgicalCareInc1;

  /// No description provided for @servicePostSurgicalCareInc2.
  ///
  /// In en, this message translates to:
  /// **'Pain management assistance'**
  String get servicePostSurgicalCareInc2;

  /// No description provided for @servicePostSurgicalCareInc3.
  ///
  /// In en, this message translates to:
  /// **'Vital signs monitoring'**
  String get servicePostSurgicalCareInc3;

  /// No description provided for @servicePostSurgicalCareInc4.
  ///
  /// In en, this message translates to:
  /// **'Medication administration'**
  String get servicePostSurgicalCareInc4;

  /// No description provided for @servicePostSurgicalCareInc5.
  ///
  /// In en, this message translates to:
  /// **'Post-operative exercises guidance'**
  String get servicePostSurgicalCareInc5;

  /// No description provided for @servicePostSurgicalCareInc6.
  ///
  /// In en, this message translates to:
  /// **'Infection prevention measures'**
  String get servicePostSurgicalCareInc6;

  /// No description provided for @serviceChronicDiseaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Chronic Disease Management'**
  String get serviceChronicDiseaseTitle;

  /// No description provided for @serviceChronicDiseaseDesc.
  ///
  /// In en, this message translates to:
  /// **'Ongoing care for diabetes, hypertension, and more'**
  String get serviceChronicDiseaseDesc;

  /// No description provided for @serviceChronicDiseaseDuration.
  ///
  /// In en, this message translates to:
  /// **'2-3 hours'**
  String get serviceChronicDiseaseDuration;

  /// No description provided for @serviceChronicDiseaseInc1.
  ///
  /// In en, this message translates to:
  /// **'Blood sugar monitoring'**
  String get serviceChronicDiseaseInc1;

  /// No description provided for @serviceChronicDiseaseInc2.
  ///
  /// In en, this message translates to:
  /// **'Blood pressure checks'**
  String get serviceChronicDiseaseInc2;

  /// No description provided for @serviceChronicDiseaseInc3.
  ///
  /// In en, this message translates to:
  /// **'Medication management'**
  String get serviceChronicDiseaseInc3;

  /// No description provided for @serviceChronicDiseaseInc4.
  ///
  /// In en, this message translates to:
  /// **'Diet counseling'**
  String get serviceChronicDiseaseInc4;

  /// No description provided for @serviceChronicDiseaseInc5.
  ///
  /// In en, this message translates to:
  /// **'Exercise guidance'**
  String get serviceChronicDiseaseInc5;

  /// No description provided for @serviceChronicDiseaseInc6.
  ///
  /// In en, this message translates to:
  /// **'Health education'**
  String get serviceChronicDiseaseInc6;

  /// No description provided for @serviceIvTherapyDurationShort.
  ///
  /// In en, this message translates to:
  /// **'30-60 min'**
  String get serviceIvTherapyDurationShort;

  /// No description provided for @serviceIvTherapyInc5.
  ///
  /// In en, this message translates to:
  /// **'Post-procedure care'**
  String get serviceIvTherapyInc5;

  /// No description provided for @serviceImScInjectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'IM/SC Injections'**
  String get serviceImScInjectionsTitle;

  /// No description provided for @serviceImScInjectionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Intramuscular and subcutaneous injections'**
  String get serviceImScInjectionsDesc;

  /// No description provided for @serviceImScInjectionsDuration.
  ///
  /// In en, this message translates to:
  /// **'15-20 min'**
  String get serviceImScInjectionsDuration;

  /// No description provided for @serviceImScInjectionsInc1.
  ///
  /// In en, this message translates to:
  /// **'Injection administration'**
  String get serviceImScInjectionsInc1;

  /// No description provided for @serviceImScInjectionsInc2.
  ///
  /// In en, this message translates to:
  /// **'Site preparation'**
  String get serviceImScInjectionsInc2;

  /// No description provided for @serviceImScInjectionsInc3.
  ///
  /// In en, this message translates to:
  /// **'Post-injection monitoring'**
  String get serviceImScInjectionsInc3;

  /// No description provided for @serviceImScInjectionsInc4.
  ///
  /// In en, this message translates to:
  /// **'Proper disposal of materials'**
  String get serviceImScInjectionsInc4;

  /// No description provided for @serviceWoundDressingTitle.
  ///
  /// In en, this message translates to:
  /// **'Wound Dressing'**
  String get serviceWoundDressingTitle;

  /// No description provided for @serviceWoundDressingDesc.
  ///
  /// In en, this message translates to:
  /// **'Professional wound cleaning and dressing'**
  String get serviceWoundDressingDesc;

  /// No description provided for @serviceWoundDressingDuration.
  ///
  /// In en, this message translates to:
  /// **'30-45 min'**
  String get serviceWoundDressingDuration;

  /// No description provided for @serviceWoundDressingInc1.
  ///
  /// In en, this message translates to:
  /// **'Wound assessment'**
  String get serviceWoundDressingInc1;

  /// No description provided for @serviceWoundDressingInc2.
  ///
  /// In en, this message translates to:
  /// **'Cleaning and disinfection'**
  String get serviceWoundDressingInc2;

  /// No description provided for @serviceWoundDressingInc3.
  ///
  /// In en, this message translates to:
  /// **'Sterile dressing application'**
  String get serviceWoundDressingInc3;

  /// No description provided for @serviceWoundDressingInc4.
  ///
  /// In en, this message translates to:
  /// **'Infection monitoring'**
  String get serviceWoundDressingInc4;

  /// No description provided for @serviceWoundDressingInc5.
  ///
  /// In en, this message translates to:
  /// **'Care instructions'**
  String get serviceWoundDressingInc5;

  /// No description provided for @serviceBurnCareTitle.
  ///
  /// In en, this message translates to:
  /// **'Burn Care'**
  String get serviceBurnCareTitle;

  /// No description provided for @serviceBurnCareDesc.
  ///
  /// In en, this message translates to:
  /// **'Specialized care for burn injuries'**
  String get serviceBurnCareDesc;

  /// No description provided for @serviceBurnCareDuration.
  ///
  /// In en, this message translates to:
  /// **'45-60 min'**
  String get serviceBurnCareDuration;

  /// No description provided for @serviceBurnCareInc1.
  ///
  /// In en, this message translates to:
  /// **'Burn assessment'**
  String get serviceBurnCareInc1;

  /// No description provided for @serviceBurnCareInc2.
  ///
  /// In en, this message translates to:
  /// **'Wound cleaning'**
  String get serviceBurnCareInc2;

  /// No description provided for @serviceBurnCareInc3.
  ///
  /// In en, this message translates to:
  /// **'Specialized dressing'**
  String get serviceBurnCareInc3;

  /// No description provided for @serviceBurnCareInc4.
  ///
  /// In en, this message translates to:
  /// **'Pain management'**
  String get serviceBurnCareInc4;

  /// No description provided for @serviceBurnCareInc5.
  ///
  /// In en, this message translates to:
  /// **'Healing monitoring'**
  String get serviceBurnCareInc5;

  /// No description provided for @serviceFractureCareTitle.
  ///
  /// In en, this message translates to:
  /// **'Fracture Care'**
  String get serviceFractureCareTitle;

  /// No description provided for @serviceFractureCareDesc.
  ///
  /// In en, this message translates to:
  /// **'Care for patients with broken bones or fractures'**
  String get serviceFractureCareDesc;

  /// No description provided for @serviceFractureCareDuration.
  ///
  /// In en, this message translates to:
  /// **'1-2 hours'**
  String get serviceFractureCareDuration;

  /// No description provided for @serviceFractureCareInc1.
  ///
  /// In en, this message translates to:
  /// **'Cast care instructions'**
  String get serviceFractureCareInc1;

  /// No description provided for @serviceFractureCareInc2.
  ///
  /// In en, this message translates to:
  /// **'Pain management'**
  String get serviceFractureCareInc2;

  /// No description provided for @serviceFractureCareInc3.
  ///
  /// In en, this message translates to:
  /// **'Mobility assistance'**
  String get serviceFractureCareInc3;

  /// No description provided for @serviceFractureCareInc4.
  ///
  /// In en, this message translates to:
  /// **'Physical therapy exercises'**
  String get serviceFractureCareInc4;

  /// No description provided for @serviceFractureCareInc5.
  ///
  /// In en, this message translates to:
  /// **'Swelling monitoring'**
  String get serviceFractureCareInc5;

  /// No description provided for @filterServices.
  ///
  /// In en, this message translates to:
  /// **'Filter Services'**
  String get filterServices;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @sortRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get sortRecommended;

  /// No description provided for @sortPriceLowToHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get sortPriceLowToHigh;

  /// No description provided for @sortPriceHighToLow.
  ///
  /// In en, this message translates to:
  /// **'Price: High to Low'**
  String get sortPriceHighToLow;

  /// No description provided for @sortHighestRated.
  ///
  /// In en, this message translates to:
  /// **'Highest Rated'**
  String get sortHighestRated;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @nursingServicesHeader.
  ///
  /// In en, this message translates to:
  /// **'Nursing\nServices'**
  String get nursingServicesHeader;

  /// No description provided for @nursingServicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore {count} premium at-home treatments.'**
  String nursingServicesSubtitle(Object count);

  /// No description provided for @searchTreatments.
  ///
  /// In en, this message translates to:
  /// **'Search treatments...'**
  String get searchTreatments;

  /// No description provided for @noServicesFound.
  ///
  /// In en, this message translates to:
  /// **'No services found'**
  String get noServicesFound;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or category'**
  String get tryDifferentSearch;

  /// No description provided for @priceEgp.
  ///
  /// In en, this message translates to:
  /// **'{price} EGP'**
  String priceEgp(Object price);

  /// No description provided for @ourServices.
  ///
  /// In en, this message translates to:
  /// **'Our Services'**
  String get ourServices;

  /// No description provided for @servicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Professional healthcare at your doorstep'**
  String get servicesSubtitle;

  /// No description provided for @searchServices.
  ///
  /// In en, this message translates to:
  /// **'Search services...'**
  String get searchServices;

  /// No description provided for @popularServices.
  ///
  /// In en, this message translates to:
  /// **'🔥 Popular Services'**
  String get popularServices;

  /// No description provided for @allServices.
  ///
  /// In en, this message translates to:
  /// **'📋 All Services'**
  String get allServices;

  /// No description provided for @popularLabel.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popularLabel;

  /// No description provided for @tryAdjustingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters'**
  String get tryAdjustingFilters;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @shareComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Share feature coming soon!'**
  String get shareComingSoon;

  /// No description provided for @professionalService.
  ///
  /// In en, this message translates to:
  /// **'Professional Service'**
  String get professionalService;

  /// No description provided for @reviewsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} reviews'**
  String reviewsCount(Object count);

  /// No description provided for @bookingsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} bookings'**
  String bookingsCount(Object count);

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @response.
  ///
  /// In en, this message translates to:
  /// **'Response'**
  String get response;

  /// No description provided for @lessThan5Min.
  ///
  /// In en, this message translates to:
  /// **'< 5 min'**
  String get lessThan5Min;

  /// No description provided for @highlightCertified.
  ///
  /// In en, this message translates to:
  /// **'Certified'**
  String get highlightCertified;

  /// No description provided for @highlightCertifiedDesc.
  ///
  /// In en, this message translates to:
  /// **'Licensed nurses'**
  String get highlightCertifiedDesc;

  /// No description provided for @highlightOnTime.
  ///
  /// In en, this message translates to:
  /// **'On-Time'**
  String get highlightOnTime;

  /// No description provided for @highlightOnTimeDesc.
  ///
  /// In en, this message translates to:
  /// **'98% punctual'**
  String get highlightOnTimeDesc;

  /// No description provided for @highlightTrusted.
  ///
  /// In en, this message translates to:
  /// **'Trusted'**
  String get highlightTrusted;

  /// No description provided for @highlightTrustedDesc.
  ///
  /// In en, this message translates to:
  /// **'5.2k+ served'**
  String get highlightTrustedDesc;

  /// No description provided for @highlightSupport.
  ///
  /// In en, this message translates to:
  /// **'24/7'**
  String get highlightSupport;

  /// No description provided for @highlightSupportDesc.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get highlightSupportDesc;

  /// No description provided for @tabIncludes.
  ///
  /// In en, this message translates to:
  /// **'Includes'**
  String get tabIncludes;

  /// No description provided for @tabReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get tabReviews;

  /// No description provided for @tabFaq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get tabFaq;

  /// No description provided for @whatsIncluded.
  ///
  /// In en, this message translates to:
  /// **'What\'s Included'**
  String get whatsIncluded;

  /// No description provided for @review1Name.
  ///
  /// In en, this message translates to:
  /// **'Ahmed M.'**
  String get review1Name;

  /// No description provided for @review1Comment.
  ///
  /// In en, this message translates to:
  /// **'Excellent service! The nurse was very professional.'**
  String get review1Comment;

  /// No description provided for @review2Name.
  ///
  /// In en, this message translates to:
  /// **'Fatima K.'**
  String get review2Name;

  /// No description provided for @review2Comment.
  ///
  /// In en, this message translates to:
  /// **'Very satisfied with the care provided. Highly recommend!'**
  String get review2Comment;

  /// No description provided for @review3Name.
  ///
  /// In en, this message translates to:
  /// **'Mohamed S.'**
  String get review3Name;

  /// No description provided for @review3Comment.
  ///
  /// In en, this message translates to:
  /// **'Good service, nurse arrived on time.'**
  String get review3Comment;

  /// No description provided for @timeAgo2Days.
  ///
  /// In en, this message translates to:
  /// **'2 days ago'**
  String get timeAgo2Days;

  /// No description provided for @timeAgo1Week.
  ///
  /// In en, this message translates to:
  /// **'1 week ago'**
  String get timeAgo1Week;

  /// No description provided for @timeAgo2Weeks.
  ///
  /// In en, this message translates to:
  /// **'2 weeks ago'**
  String get timeAgo2Weeks;

  /// No description provided for @faq1Q.
  ///
  /// In en, this message translates to:
  /// **'How do I prepare for the service?'**
  String get faq1Q;

  /// No description provided for @faq1A.
  ///
  /// In en, this message translates to:
  /// **'Ensure a clean, comfortable space for the nurse to work. Have any relevant medical documents ready.'**
  String get faq1A;

  /// No description provided for @faq2Q.
  ///
  /// In en, this message translates to:
  /// **'Can I reschedule my booking?'**
  String get faq2Q;

  /// No description provided for @faq2A.
  ///
  /// In en, this message translates to:
  /// **'Yes, you can reschedule up to 2 hours before your appointment without any charges.'**
  String get faq2A;

  /// No description provided for @faq3Q.
  ///
  /// In en, this message translates to:
  /// **'What if I need to cancel?'**
  String get faq3Q;

  /// No description provided for @faq3A.
  ///
  /// In en, this message translates to:
  /// **'Cancellations made 2+ hours before are free. Late cancellations may incur a small fee.'**
  String get faq3A;

  /// No description provided for @verifiedNursesOnly.
  ///
  /// In en, this message translates to:
  /// **'Verified Nurses Only'**
  String get verifiedNursesOnly;

  /// No description provided for @verifiedNursesDesc.
  ///
  /// In en, this message translates to:
  /// **'All nurses are licensed, background-checked, and highly rated by patients.'**
  String get verifiedNursesDesc;

  /// No description provided for @satisfactionGuarantee.
  ///
  /// In en, this message translates to:
  /// **'Satisfaction Guarantee'**
  String get satisfactionGuarantee;

  /// No description provided for @satisfactionGuaranteeDesc.
  ///
  /// In en, this message translates to:
  /// **'100% Money back if not satisfied'**
  String get satisfactionGuaranteeDesc;

  /// No description provided for @freeReschedule.
  ///
  /// In en, this message translates to:
  /// **'Free Reschedule'**
  String get freeReschedule;

  /// No description provided for @easyRefund.
  ///
  /// In en, this message translates to:
  /// **'Easy Refund'**
  String get easyRefund;

  /// No description provided for @support247.
  ///
  /// In en, this message translates to:
  /// **'24/7 Support'**
  String get support247;

  /// No description provided for @totalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total Price'**
  String get totalPrice;

  /// No description provided for @perVisit.
  ///
  /// In en, this message translates to:
  /// **'/visit'**
  String get perVisit;

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookNow;

  /// No description provided for @serviceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Service is currently unavailable. Please try another service.'**
  String get serviceUnavailable;
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
