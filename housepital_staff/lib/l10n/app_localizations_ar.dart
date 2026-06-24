// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'هاوسبيتال طاقم العمل';

  @override
  String get home => 'الرئيسية';

  @override
  String get history => 'السجل';

  @override
  String get wallet => 'المحفظة';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get settings => 'الإعدادات';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodAfternoon => 'مساء الخير';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String get nurse => 'ممرض/ة';

  @override
  String get nurseMale => 'ممرض';

  @override
  String get nurseFemale => 'ممرضه';

  @override
  String get online => 'متاح';

  @override
  String get offline => 'غير متصل';

  @override
  String get goOnlineToStart => 'اتصل بالإنترنت للبدء';

  @override
  String get visibleToPatients => 'أنت مرئي للمرضى الآن';

  @override
  String get scanningPatients => 'جارٍ البحث عن مرضى بالجوار...';

  @override
  String get requestsAppearAuto => 'ستظهر الطلبات تلقائياً';

  @override
  String get newRequest => 'طلب جديد';

  @override
  String get patientWaiting => 'هناك مريض ينتظر رعايتك';

  @override
  String get viewVisitDetails => 'عرض تفاصيل الزيارة';

  @override
  String get accept => 'قبول';

  @override
  String get decline => 'رفض';

  @override
  String get close => 'إغلاق';

  @override
  String get visitInfo => 'معلومات الزيارة';

  @override
  String get serviceRequested => 'الخدمة المطلوبة';

  @override
  String get timing => 'التوقيت';

  @override
  String get asapRequest => 'طلب عاجل (أسرع وقت)';

  @override
  String get scheduledVisit => 'زيارة مجدولة';

  @override
  String get scheduleTitle => 'جدولي';

  @override
  String get location => 'الموقع';

  @override
  String get patientNotes => 'ملاحظات المريض';

  @override
  String get totalEarning => 'إجمالي الربح';

  @override
  String get egp => 'جنيه';

  @override
  String get offerAccepted => 'تم قبول العرض';

  @override
  String get waitingPatientConfirm => 'بانتظار تأكيد المريض...';

  @override
  String get verifyVisit => 'تأكيد الزيارة';

  @override
  String get enterSecurityCode => 'أدخل رمز الأمان';

  @override
  String get askPatientCode => 'اطلب من المريض الرمز المكون من 4 أرقام';

  @override
  String get startVisit => 'بدء الزيارة';

  @override
  String get cancelVisit => 'إلغاء الزيارة';

  @override
  String get visitInProgress => 'الزيارة قيد التنفيذ';

  @override
  String get liveDuration => 'الوقت المستغرق';

  @override
  String get sessionOverview => 'نظرة عامة على الجلسة';

  @override
  String get started => 'بدأت في';

  @override
  String get type => 'النوع';

  @override
  String get inPerson => 'زيارة منزلية';

  @override
  String get patientRecord => 'سجل المريض';

  @override
  String get serviceDetails => 'تفاصيل الخدمة';

  @override
  String get completeReportForm => 'أكمل نموذج التقرير';

  @override
  String fieldsRemaining(int count) {
    return 'تبقي $count حقول';
  }

  @override
  String get visitReport => 'تقرير الزيارة';

  @override
  String get completeVisit => 'إتمام الزيارة';

  @override
  String get fillVitalsToComplete => 'يرجى ملء جميع العلامات الحيوية للإتمام';

  @override
  String get confirmCompleteTitle => 'إتمام الزيارة؟';

  @override
  String get confirmCompleteSub =>
      'سيؤدي هذا إلى إنهاء الزيارة وخصم عمولة المنصة من محفظتك.';

  @override
  String get goBack => 'رجوع';

  @override
  String get visitCompleted => 'تمت الزيارة بنجاح!';

  @override
  String get visitCompletedSub =>
      'عمل رائع! تم إنشاء تقرير الزيارة وإنهاء الجلسة بنجاح.';

  @override
  String get documentation => 'التوثيق';

  @override
  String get sharePdf => 'مشاركة PDF';

  @override
  String get previewReport => 'معاينة التقرير';

  @override
  String get backToHome => 'العودة للرئيسية';

  @override
  String get patientStatus => 'حالة المريض';

  @override
  String get assessCondition => 'تقييم الحالة العامة';

  @override
  String get overallCondition => 'الحالة العامة *';

  @override
  String get consciousnessLevel => 'مستوى الوعي *';

  @override
  String get painLevel => 'مستوى الألم';

  @override
  String get mobility => 'الحركة';

  @override
  String get woundCondition => 'حالة الجرح / موضع الكانيولا';

  @override
  String get vitalSigns => 'العلامات الحيوية';

  @override
  String get requiredBeforeComplete => 'مطلوب قبل الإتمام';

  @override
  String get bloodPressure => 'ضغط الدم';

  @override
  String get heartRate => 'نبض القلب';

  @override
  String get temperature => 'درجة الحرارة';

  @override
  String get oxygenSaturation => 'تشبع الأكسجين (SpO₂)';

  @override
  String get optionalVitals => 'معدل التنفس، سكر الدم، الوزن';

  @override
  String get hideOptional => 'إخفاء العلامات الاختيارية';

  @override
  String get showOptional => '+ معدل التنفس، سكر الدم، الوزن';

  @override
  String get careProvided => 'الرعاية المقدمة';

  @override
  String get whatWasDone => 'ما تم القيام به خلال الزيارة';

  @override
  String get servicesPerformed => 'الخدمات المؤداة *';

  @override
  String get medicationsGiven => 'الأدوية المعطاة';

  @override
  String get addMedication => 'إضافة دواء';

  @override
  String get proceduresPerformed => 'الإجراءات المؤداة';

  @override
  String get patientCooperation => 'تعاون المريض';

  @override
  String get notesObservations => 'ملاحظات وتنبيهات';

  @override
  String get clinicalObservations => 'الملاحظات السريرية';

  @override
  String get familyPresent => 'وجود الأهل / المرافق';

  @override
  String get homeEnvironment => 'بيئة المنزل';

  @override
  String get familyConcerns => 'مخاوف المريض / الأهل';

  @override
  String get followUpAlerts => 'المتابعة والتنبيهات';

  @override
  String get nextSteps => 'الخطوات التالية للمريض';

  @override
  String get followUpRequired => 'هل المتابعة مطلوبة؟';

  @override
  String get urgencyLevel => 'مستوى الأهمية';

  @override
  String get recommendedActions => 'الإجراءات الموصى بها';

  @override
  String get alertCareTeam => 'تنبيه لفريق الرعاية';

  @override
  String get myWallet => 'محفظتي';

  @override
  String get rechargeWallet => 'شحن المحفظة';

  @override
  String minThreshold(String amount) {
    return 'الحد الأدنى: $amount جنيه';
  }

  @override
  String commission(String rate) {
    return 'العمولة: $rate%';
  }

  @override
  String get accountRestricted => 'الحساب مقيد';

  @override
  String get transactionHistory => 'سجل المعاملات';

  @override
  String get myProfile => 'ملفي الشخصي';

  @override
  String get editProfileData => 'تعديل البيانات';

  @override
  String get personalDetails => 'البيانات الشخصية';

  @override
  String get professionalDetails => 'البيانات المهنية';

  @override
  String get skills => 'المهارات';

  @override
  String get credentials => 'المؤهلات المهنية';

  @override
  String get serviceAreas => 'مناطق الخدمة';

  @override
  String get performanceReviews => 'الأداء والتقييمات';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get darkMode => 'الوضع الليلي';

  @override
  String get language => 'اللغة';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get yourWorkZone => 'منطقة عملك';

  @override
  String get change => 'تغيير';

  @override
  String get mapEditingSoon => 'تعديل الخريطة قريباً';

  @override
  String get appPreferences => 'تفضيلات التطبيق';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get darkThemeEnabled => 'الوضع الداكن مفعل';

  @override
  String get lightThemeEnabled => 'الوضع الفاتح مفعل';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get closeButton => 'إغلاق';

  @override
  String get passwordUpdated => 'تم تحديث كلمة المرور بنجاح!';

  @override
  String get privacyPolicyContent =>
      'خصوصيتك تهمنا. يقوم Housepital بتشفير جميع بيانات المستخدم والمريض بشكل آمن.';

  @override
  String get termsOfServiceContent =>
      'تحكم شروط خدمة Housepital استخدامك لهذه المنصة.';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get appVersion => 'تطبيق Housepital للطاقم إصدار 1.0.0';

  @override
  String get security => 'الأمان';

  @override
  String get about => 'حول التطبيق';

  @override
  String get noPerformanceData => 'لا تتوفر بيانات أداء';

  @override
  String get myPerformance => 'أدائي';

  @override
  String get patientReviewsTitle => 'تقييمات المرضى';

  @override
  String get reviewsCountText => 'التقييمات';

  @override
  String get visitsStat => 'الزيارات';

  @override
  String get rateStat => 'المعدل';

  @override
  String get noReviewsYet => 'لا توجد تقييمات بعد';

  @override
  String get patientFeedbackDesc =>
      'ستظهر آراء المرضى هنا بمجرد البدء في إكمال الزيارات.';

  @override
  String get noSessionsYet => 'لا توجد جلسات بعد';

  @override
  String get historyEmptyDesc => 'ستظهر زياراتك المكتملة والملغاة هنا.';

  @override
  String get completedStatus => 'مكتملة';

  @override
  String get cancelledStatus => 'ملغاة';

  @override
  String get durationLabel => 'المدة';

  @override
  String get failedToLoadPaymentInfo => 'فشل في تحميل معلومات الدفع';

  @override
  String get somethingWentWrong => 'حدث خطأ ما';

  @override
  String get blockedLabel => 'محظور';

  @override
  String get walletBlockedDesc => 'لقد تجاوز رصيد محفظتك الحد الأدنى.';

  @override
  String get rechargeToUnblockDesc => 'اشحن محفظتك لفك حظر حسابك.';

  @override
  String get rechargeToUnblockButton => 'اشحن لفك الحظر';

  @override
  String get myReceiptsTitle => 'إيصالاتي';

  @override
  String get trackReceiptsDesc => 'تتبع حالة طلبات الشحن الخاصة بك';

  @override
  String get approvedStatus => 'مقبول';

  @override
  String get rejectedStatus => 'مرفوض';

  @override
  String get pendingStatus => 'قيد الانتظار';

  @override
  String get reasonLabel => 'السبب';

  @override
  String get noTransactionsYet => 'لا توجد معاملات بعد';

  @override
  String get transferAmountDesc => 'قم بتحويل المبلغ ثم ارفع إيصالك.';

  @override
  String get paymentMethodLabel => 'طريقة الدفع';

  @override
  String get instapayDetails => '📱 تفاصيل انستا باي';

  @override
  String get mobileWalletDetails => '📱 تفاصيل المحفظة الإلكترونية';

  @override
  String get phoneLabel => 'الهاتف';

  @override
  String get nameLabel => 'الاسم';

  @override
  String get linkLabel => 'الرابط';

  @override
  String get amountLabel => 'المبلغ';

  @override
  String get min10Label => 'الحد الأدنى ١٠';

  @override
  String get tapToUploadReceipt => 'اضغط لرفع صورة الإيصال';

  @override
  String get receiptUploaded => 'تم رفع الإيصال ✓';

  @override
  String get changePhoto => 'تغيير الصورة';

  @override
  String get submittingBtn => 'جاري التقديم...';

  @override
  String get submitReceiptBtn => 'تقديم الإيصال';

  @override
  String get viewStatus => 'عرض الحالة';

  @override
  String get finishSetup => 'إتمام الإعداد';

  @override
  String get fixNow => 'إصلاح الآن';

  @override
  String get profileApprovalRequired =>
      'لا يمكنك استلام الطلبات حتى يتمت الموافقة على ملفك الشخصي.';

  @override
  String get reviewDuration =>
      'نحن نقوم بمراجعة ملفك الشخصي. يستغرق هذا عادةً 24 ساعة.';

  @override
  String get updateDocuments => 'يرجى تحديث مستنداتك.';

  @override
  String get serviceVitalSigns => 'قياس العلامات الحيوية';

  @override
  String get serviceWoundCare => 'العناية بالجروح';

  @override
  String get serviceMedicationAdmin => 'إعطاء الأدوية';

  @override
  String get serviceIvCare => 'العناية بالوريد';

  @override
  String get servicePatientEducation => 'تثقيف المريض';

  @override
  String get servicePainAssessment => 'تقييم الألم';

  @override
  String get serviceMobilityAssist => 'المساعدة في الحركة';
}
