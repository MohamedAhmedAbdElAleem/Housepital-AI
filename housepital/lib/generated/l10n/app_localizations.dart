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
