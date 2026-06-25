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
