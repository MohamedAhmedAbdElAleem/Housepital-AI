// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navBookings => 'الحجوزات';

  @override
  String get navAI => 'مساعد الذكاء الاصطناعي';

  @override
  String get navAlerts => 'التنبيهات';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get visitCompletedTitle => 'اكتملت الزيارة';

  @override
  String visitCompletedSubtitle(Object nurseName) {
    return 'الرعاية بواسطة $nurseName';
  }

  @override
  String get orderSummaryTitle => 'ملخص الطلب';

  @override
  String get serviceLabel => 'الخدمة';

  @override
  String get destinationFeeLabel => 'رسوم الوجهة';

  @override
  String get platformFeeLabel => 'رسوم المنصة';

  @override
  String get totalLabel => 'الإجمالي';

  @override
  String get visitReportTitle => 'تقرير الزيارة';

  @override
  String rateNurseTitle(Object nurseName) {
    return 'قيّم $nurseName';
  }

  @override
  String get ratingSubmittedTitle => 'تم إرسال التقييم';

  @override
  String get ratingPrompt => 'كيف كانت الخدمة المقدمة؟';

  @override
  String get ratingThanks => 'شكرًا لملاحظاتك!';

  @override
  String get ratingSelectError => 'يرجى اختيار تقييم';

  @override
  String get reviewHint => 'اكتب مراجعة (اختياري)...';

  @override
  String get submitRating => 'إرسال التقييم';

  @override
  String get submitting => 'جارٍ الإرسال...';

  @override
  String get ratingThanksSnack => 'شكرًا على التقييم!';

  @override
  String get ratingSaved => 'تم حفظ التقييم بنجاح!';

  @override
  String get backToHome => 'العودة إلى الرئيسية';

  @override
  String get currencyEgp => 'ج.م';

  @override
  String get defaultNurseName => 'الممرض';
}
