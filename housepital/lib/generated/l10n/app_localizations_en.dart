// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
