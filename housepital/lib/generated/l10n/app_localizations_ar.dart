// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'هاوسبيتال';

  @override
  String get appTagline => 'رعاية صحية منزلية بالذكاء الاصطناعي';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get settings => 'الإعدادات';

  @override
  String get appearanceLanguage => 'المظهر واللغة';

  @override
  String get theme => 'المظهر';

  @override
  String get language => 'اللغة';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get onboarding1Title => 'رعاية احترافية\nعند باب منزلك';

  @override
  String get onboarding1Desc =>
      'احصل على ممرضين معتمدين ومتخصصين في الرعاية الصحية\nبمنزلك، عند الطلب أو بجدولة مسبقة';

  @override
  String get onboarding2Title => 'مساعد رعاية صحية\nبالذكاء الاصطناعي';

  @override
  String get onboarding2Desc =>
      'توصيات ذكية ودعم على مدار الساعة\nمع رفيق الرعاية الصحية الذكي الخاص بنا';

  @override
  String get next => 'التالي';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get skipIntro => 'تخطي المقدمة';

  @override
  String get version => 'الإصدار 1.0.0';

  @override
  String get loginTitle => 'مرحباً بعودتك';

  @override
  String get loginSubtitle => 'قم بتسجيل الدخول إلى حسابك';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get emailHint => 'أدخل بريدك الإلكتروني';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get passwordHint => 'أدخل كلمة المرور';

  @override
  String get rememberMe => 'تذكرني';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get registerHere => 'سجل هنا';

  @override
  String get orLoginWith => 'أو سجل الدخول عبر';

  @override
  String get google => 'جوجل';

  @override
  String get apple => 'أبل';

  @override
  String get sessionExpired => 'انتهت الجلسة. يرجى تسجيل الدخول بكلمة المرور.';

  @override
  String get warningEmptyEmail => 'يرجى إدخال البريد الإلكتروني';

  @override
  String get warningInvalidEmail => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get warningEmptyPassword => 'يرجى إدخال كلمة المرور';

  @override
  String get errorInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة';

  @override
  String get forgotPasswordTitle => 'هل نسيت كلمة المرور؟';

  @override
  String get forgotPasswordSubtitle => '🔐 لا تقلق! سنساعدك في استعادتها';

  @override
  String get resetViaEmail => 'إعادة التعيين عبر البريد';

  @override
  String get sendVerificationCodeDesc => 'سنرسل لك رمز تحقق';

  @override
  String get emailHintForgot => 'أدخل بريدك المسجل';

  @override
  String get sendCodeButton => 'إرسال رمز التحقق';

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String get securityTips => 'نصائح الأمان';

  @override
  String get tipSpamFolder =>
      'تحقق من مجلد الرسائل غير المرغوب فيها إذا لم تجد الرسالة';

  @override
  String get tipCodeExpiry => 'تنتهي صلاحية الرمز خلال 10 دقائق';

  @override
  String get tipNeverShare => 'لا تشارك الرمز مع أي شخص أبدًا';

  @override
  String get backToLogin => 'العودة لتسجيل الدخول';

  @override
  String get otpSentSuccess => 'تم إرسال رمز التحقق إلى بريدك';

  @override
  String get otpSendFailed => 'فشل إرسال الرمز';

  @override
  String get noInternet => 'لا يوجد اتصال بالإنترنت';

  @override
  String get somethingWentWrong => 'حدث خطأ ما';

  @override
  String get createAccountTitle => 'إنشاء حساب';

  @override
  String get registerSubtitle => '🏥 انضم إلينا لرعاية صحية أفضل';

  @override
  String registrationStep(Object current, Object total) {
    return 'الخطوة $current من $total';
  }

  @override
  String get fullNameLabel => 'الاسم الكامل';

  @override
  String get fullNameHint => 'أدخل اسمك الكامل';

  @override
  String get mobileLabel => 'رقم الموبايل';

  @override
  String get mobileHint => '01012345678';

  @override
  String get passwordHintRegister => 'أنشئ كلمة مرور قوية';

  @override
  String get confirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get confirmPasswordHint => 'أعد إدخال كلمة المرور';

  @override
  String get agreeTo => 'أوافق على ';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get and => ' و ';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get passwordTooShort => 'قصيرة جدًا';

  @override
  String get passwordWeak => 'ضعيفة';

  @override
  String get passwordMedium => 'متوسطة';

  @override
  String get passwordStrong => 'قوية';

  @override
  String get passwordVeryStrong => 'قوية جدًا';

  @override
  String get warningEmptyName => 'يرجى إدخال اسمك الكامل';

  @override
  String get warningShortName => 'يجب أن يكون الاسم 3 أحرف على الأقل';

  @override
  String get warningEmptyMobile => 'يرجى إدخال رقم الموبايل';

  @override
  String get warningInvalidMobile => 'يرجى إدخال رقم موبايل مصري صحيح';

  @override
  String get warningEmptyConfirmPassword => 'يرجى تأكيد كلمة المرور';

  @override
  String get warningPasswordMismatch => 'كلمات المرور غير متطابقة';

  @override
  String get warningAgreeTerms => 'يرجى الموافقة على شروط الخدمة';

  @override
  String get registrationSuccess => 'تم التسجيل بنجاح! أكمل ملفك الشخصي';

  @override
  String get serverError => 'خطأ في السيرفر. يرجى المحاولة لاحقًا';

  @override
  String get verifyEmailTitle => 'تأكيد بريدك الإلكتروني';

  @override
  String get otpVerifySuccess => 'تم تأكيد البريد بنجاح!';

  @override
  String get tooManyAttempts => 'محاولات كثيرة فاشلة. اطلب رمزًا جديدًا.';

  @override
  String get warningCompleteOtp => 'يرجى إدخال الرمز المكون من 6 أرقام';

  @override
  String invalidOtpRemaining(Object remaining) {
    return 'رمز غير صحيح. متبقي $remaining محاولات.';
  }

  @override
  String get accountLocked => 'الحساب مغلق! اطلب رمزًا جديدًا.';

  @override
  String get waitBeforeResend => 'يرجى الانتظار قبل طلب رمز جديد';

  @override
  String get newOtpSent => 'تم إرسال رمز تحقق جديد!';

  @override
  String get resendFailed => 'فشل إعادة إرسال الرمز';

  @override
  String get codeExpiresIn => 'تنتهي صلاحية الرمز خلال';

  @override
  String get enterVerificationCode => 'أدخل رمز التحقق';

  @override
  String attemptIndicator(Object current, Object total) {
    return 'محاولة $current من $total';
  }

  @override
  String get didntReceiveCode => 'لم تستلم الرمز؟';

  @override
  String get resend => 'إعادة الإرسال';

  @override
  String get verifyEmailButton => 'تأكيد البريد';

  @override
  String get locked => 'مغلق';

  @override
  String get securityNotice => 'تنبيه أمني';

  @override
  String get securityNoticeDesc =>
      'لا تشارك هذا الرمز مع أي شخص أبدًا. فريقنا لن يطلبه منك.';

  @override
  String get createNewPasswordTitle => 'إنشاء كلمة مرور جديدة';

  @override
  String get newPasswordSubtitle => '🔒 اجعلها قوية وفريدة';

  @override
  String get newPasswordLabel => 'كلمة المرور الجديدة';

  @override
  String get passwordRequirements => 'متطلبات كلمة المرور';

  @override
  String get min6Chars => '6 أحرف على الأقل';

  @override
  String get passwordsMatch => 'كلمات المرور متطابقة';

  @override
  String get resetPasswordButton => 'إعادة تعيين كلمة المرور';

  @override
  String get passwordTips => 'نصائح كلمة المرور';

  @override
  String get tipMixChars => 'استخدم مزيجًا من الحروف والأرقام والرموز';

  @override
  String get tipAvoidPersonalInfo => 'تجنب استخدام معلوماتك الشخصية';

  @override
  String get tipDontReuse => 'لا تكرر استخدام كلمات مرور من مواقع أخرى';

  @override
  String get warningEmptyNewPassword => 'يرجى إدخال كلمة مرور جديدة';

  @override
  String get resetFailed => 'فشل إعادة تعيين كلمة المرور';

  @override
  String get resetSuccessTitle => 'تمت إعادة تعيين\nكلمة المرور بنجاح! 🎉';

  @override
  String get resetSuccessSubtitle =>
      'تم تغيير كلمة المرور الخاصة بك بنجاح.\nيمكنك الآن تسجيل الدخول بكلمة المرور الجديدة.';

  @override
  String get tipPrivatePassword => 'حافظ على خصوصية كلمة مرورك';

  @override
  String get tipChangeRegularly => 'قم بتغييرها كل 3-6 أشهر';

  @override
  String get tipSignOutUnknown => 'سجل الخروج من الأجهزة غير المعروفة';

  @override
  String get verificationSuccessTitle => 'تم التأكيد\nبنجاح! 🎉';

  @override
  String get verificationSuccessSubtitle => 'تم تأكيد هويتك بنجاح';

  @override
  String get identityVerified => 'تم تأكيد الهوية';

  @override
  String get idConfirmed => 'تم تأكيد هويتك';

  @override
  String get documentsApproved => 'تمت الموافقة على المستندات';

  @override
  String get documentsValid => 'جميع المستندات صالحة';

  @override
  String get accountSecured => 'الحساب مؤمن';

  @override
  String get accountProtected => 'حسابك محمي';

  @override
  String get done => 'تم';

  @override
  String get whatYouCanDo => 'ما يمكنك فعله الآن';

  @override
  String get bookServices => 'حجز الخدمات الطبية';

  @override
  String get requestVisits => 'طلب زيارات منزلية';

  @override
  String get chatProviders => 'الدردشة مع مقدمي الرعاية';

  @override
  String get accessHistory => 'الوصول لسجلك الطبي';

  @override
  String get continueToLogin => 'المتابعة لتسجيل الدخول';

  @override
  String get medicalHistoryTitle => 'السجل الطبي';

  @override
  String get skip => 'تخطي';

  @override
  String get stepInfo => 'المعلومات';

  @override
  String get stepMedical => 'طبي';

  @override
  String get stepId => 'الهوية';

  @override
  String get healthInfoTitle => 'المعلومات الصحية';

  @override
  String get healthInfoSubtitle => 'ساعدنا لنقدم لك رعاية أفضل';

  @override
  String get healthInfoSafetyDesc =>
      'تساعد هذه المعلومات فريقنا الطبي على الاستعداد بشكل أفضل لزياراتك وضمان سلامتك.';

  @override
  String get bloodTypeTitle => 'فصيلة الدم';

  @override
  String get optionalLabel => '(اختياري)';

  @override
  String get chronicDiseasesTitle => 'الأمراض المزمنة';

  @override
  String get noChronicDiseases => 'ليس لدي أي أمراض مزمنة';

  @override
  String get allergiesTitle => 'الحساسية';

  @override
  String get noAllergies => 'ليس لدي أي أنواع حساسية معروفة';

  @override
  String get otherConditionsTitle => 'حالات طبية أخرى';

  @override
  String get otherConditionsHint => 'صف أي حالات طبية أخرى...';

  @override
  String get currentMedicationsTitle => 'الأدوية الحالية';

  @override
  String get currentMedicationsHint => 'اذكر أي أدوية تتناولها حالياً...';

  @override
  String get saving => 'جاري الحفظ...';

  @override
  String get continueButton => 'المتابعة';

  @override
  String get saveMedicalInfoError =>
      'تعذر حفظ المعلومات الطبية. يمكنك تحديثها لاحقاً.';

  @override
  String get diabetes => 'السكري';

  @override
  String get highBloodPressure => 'ارتفاع ضغط الدم';

  @override
  String get heartDisease => 'أمراض القلب';

  @override
  String get asthma => 'الربو';

  @override
  String get kidneyDisease => 'أمراض الكلى';

  @override
  String get liverDisease => 'أمراض الكبد';

  @override
  String get cancer => 'السرطان';

  @override
  String get thyroidDisorder => 'اضطراب الغدة الدرقية';

  @override
  String get arthritis => 'التهاب المفاصل';

  @override
  String get epilepsy => 'الصرع';

  @override
  String get penicillin => 'البنسلين';

  @override
  String get sulfaDrugs => 'أدوية السلفا';

  @override
  String get aspirin => 'الأسبرين';

  @override
  String get ibuprofen => 'الإيبوبروفين';

  @override
  String get latex => 'اللاتكس';

  @override
  String get peanuts => 'الفول السوداني';

  @override
  String get shellfish => 'المحار';

  @override
  String get eggs => 'البيض';

  @override
  String get verifyIdentityTitle => 'تأكيد هويتك';

  @override
  String get skipForNow => 'تخطي حالياً';

  @override
  String get verifyIdentityDesc =>
      'كخدمة طبية مرخصة، نحتاج إلى تأكيد هويتك لضمان السلامة والثقة للجميع.';

  @override
  String get securePrivateTitle => 'آمن وخصوصي';

  @override
  String get securePrivateDesc => 'بياناتك مشفرة ومحمية بالكامل';

  @override
  String get quickProcessTitle => 'عملية سريعة';

  @override
  String get quickProcessDesc => 'يستغرق التأكيد أقل من دقيقتين';

  @override
  String get oneTimeOnlyTitle => 'لمرة واحدة فقط';

  @override
  String get oneTimeOnlyDesc => 'أكد هويتك مرة واحدة، واستخدم جميع الخدمات';

  @override
  String get verifyNowButton => 'أكد هويتك الآن';

  @override
  String get doItLater => 'سأقوم بذلك لاحقاً';

  @override
  String get idVerificationTitle => 'تأكيد الهوية';

  @override
  String get scanFrontSide => 'مسح الوجه الأمامي';

  @override
  String get scanBackSide => 'مسح الوجه الخلفي';

  @override
  String stepXofY(Object current, Object total) {
    return 'الخطوة $current من $total';
  }

  @override
  String get frontLabel => 'الأمامي';

  @override
  String get backLabel => 'الخلفي';

  @override
  String get positionFrontId => 'ضع الوجه الأمامي للبطاقة';

  @override
  String get positionBackId => 'ضع الوجه الخلفي للبطاقة';

  @override
  String get keepWithinFrame => 'أبقِ البطاقة داخل الإطار';

  @override
  String get tipsForResults => 'نصائح لأفضل النتائج';

  @override
  String get goodLighting => 'تأكد من وجود إضاءة جيدة';

  @override
  String get flatAligned => 'أبقِ البطاقة مسطحة ومحاذية';

  @override
  String get avoidBlur => 'تجنب الاهتزاز والانعكاسات';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get uploadGallery => 'رفع من الاستوديو';

  @override
  String get processingImage => 'جاري معالجة الصورة...';

  @override
  String get pleaseWait => 'يرجى الانتظار';

  @override
  String get uploadingDocs => 'جاري رفع المستندات...';

  @override
  String get securelySavingId => 'حفظ هويتك بشكل آمن';

  @override
  String get encryptedConnection => 'اتصال مشفر بالكامل';

  @override
  String idPreview(Object side) {
    return 'معاينة الوجه $side';
  }

  @override
  String get clearReadablePrompt => 'تأكد من أن جميع التفاصيل واضحة ومقروءة';

  @override
  String get retake => 'إعادة التقاط';

  @override
  String get upload => 'رفع';

  @override
  String get frontSide => 'الأمامي';

  @override
  String get backSide => 'الخلفي';

  @override
  String get cameraError => 'تعذر فتح الكاميرا';

  @override
  String get galleryError => 'تعذر فتح الاستوديو';

  @override
  String get noImageError => 'لم يتم اختيار صورة';

  @override
  String get processImageError => 'تعذر معالجة الصورة';

  @override
  String uploadFailed(Object error) {
    return 'فشل الرفع: $error';
  }

  @override
  String get docsSubmittedTitle => 'تم تسليم المستندات!';

  @override
  String get docsSubmittedDesc =>
      'لقد تم إرسال هويتك للمراجعة.\nسيقوم فريقنا بالتحقق منها قريباً.';

  @override
  String get pendingAdminReview => 'بانتظار مراجعة الإدارة';

  @override
  String get takes24to48Hours => 'يستغرق عادة 24-48 ساعة';

  @override
  String get gotItContinue => 'حسناً، متابعة';

  @override
  String get reviewNotice => 'يمكنك البدء باستخدام التطبيق أثناء المراجعة';

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
