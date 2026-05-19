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
  String get appTagline => 'رعاية صحية منزلية مدعومة بالذكاء الاصطناعي';

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
      'احصل على ممرضين ومعتمدين ومحترفين في الرعاية الصحية\nيصلون إلى منزلك، عند الطلب أو بجدولة مسبقة';

  @override
  String get onboarding2Title => 'مساعد رعاية صحية\nبالذكاء الاصطناعي';

  @override
  String get onboarding2Desc =>
      'توصيات ذكية ودعم على مدار الساعة مع\nرفيق الرعاية الصحية الذكي الخاص بنا';

  @override
  String get next => 'التالي';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get skipIntro => 'تخطي';

  @override
  String get version => 'الإصدار 1.0.0';

  @override
  String get loginTitle => 'مرحباً بعودتك';

  @override
  String get loginSubtitle => 'سجل دخولك إلى حساب هاوسبيتال الخاص بك';

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
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get registerHere => 'سجل هنا';

  @override
  String get orLoginWith => 'أو سجل دخولك بواسطة';

  @override
  String get google => 'جوجل';

  @override
  String get apple => 'أبل';

  @override
  String get sessionExpired => 'انتهت الجلسة. يرجى تسجيل الدخول بكلمة المرور.';

  @override
  String get warningEmptyEmail => 'يرجى إدخال بريدك الإلكتروني';

  @override
  String get warningInvalidEmail => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get warningEmptyPassword => 'يرجى إدخال كلمة المرور';

  @override
  String get errorInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة';

  @override
  String get forgotPasswordTitle => 'نسيت كلمة المرور؟';

  @override
  String get forgotPasswordSubtitle => '🔐 لا تقلق! سنساعدك في استعادتها';

  @override
  String get resetViaEmail => 'إعادة تعيين عبر البريد الإلكتروني';

  @override
  String get sendVerificationCodeDesc => 'سنرسل لك رمز تأكيد';

  @override
  String get emailHintForgot => 'أدخل بريدك الإلكتروني المسجل';

  @override
  String get sendCodeButton => 'إرسال رمز التأكيد';

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String get securityTips => 'نصائح أمنية';

  @override
  String get tipSpamFolder =>
      'افحص ملف البريد المزعج (Spam) إذا لم تجد الرسالة';

  @override
  String get tipCodeExpiry => 'الرمز صالح لمدة 10 دقائق';

  @override
  String get tipNeverShare => 'لا تشارك الرمز مع أي شخص أبداً';

  @override
  String get backToLogin => 'العودة لتسجيل الدخول';

  @override
  String get otpSentSuccess => 'تم إرسال رمز التأكيد إلى بريدك الإلكتروني';

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
    return 'خطوة $current من $total';
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
  String get passwordTooShort => 'قصيرة جداً';

  @override
  String get passwordWeak => 'ضعيفة';

  @override
  String get passwordMedium => 'متوسطة';

  @override
  String get passwordStrong => 'قوية';

  @override
  String get passwordVeryStrong => 'قوية جداً';

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
  String get serverError => 'خطأ في السيرفر. يرجى المحاولة مرة أخرى';

  @override
  String get verifyEmailTitle => 'تأكيد بريدك الإلكتروني';

  @override
  String get otpVerifySuccess => 'تم تأكيد البريد بنجاح!';

  @override
  String get tooManyAttempts => 'محاولات كثيرة خاطئة. اطلب رمزاً جديداً.';

  @override
  String get warningCompleteOtp => 'يرجى إدخال الرمز المكون من 6 أرقام';

  @override
  String invalidOtpRemaining(Object remaining) {
    return 'رمز غير صحيح. متبقي $remaining محاولات.';
  }

  @override
  String get accountLocked => 'الحساب مقفل! اطلب رمزاً جديداً.';

  @override
  String get waitBeforeResend => 'يرجى الانتظار قبل طلب رمز جديد';

  @override
  String get newOtpSent => 'تم إرسال رمز تأكيد جديد!';

  @override
  String get resendFailed => 'فشل إعادة إرسال الرمز';

  @override
  String get codeExpiresIn => 'ينتهي الرمز خلال';

  @override
  String get enterVerificationCode => 'أدخل رمز التأكيد';

  @override
  String attemptIndicator(Object current, Object total) {
    return 'محاولة $current من $total';
  }

  @override
  String get didntReceiveCode => 'لم تصلك الرسالة؟';

  @override
  String get resend => 'إعادة إرسال';

  @override
  String get verifyEmailButton => 'تأكيد البريد';

  @override
  String get locked => 'مقفل';

  @override
  String get securityNotice => 'تنبيه أمني';

  @override
  String get securityNoticeDesc =>
      'لا تشارك هذا الرمز مع أحد. فريقنا لن يطلبه منك أبداً.';

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
  String get passwordTips => 'نصائح لكلمة المرور';

  @override
  String get tipMixChars => 'استخدم مزيجاً من الحروف والأرقام والرموز';

  @override
  String get tipAvoidPersonalInfo => 'تجنب استخدام معلوماتك الشخصية';

  @override
  String get tipDontReuse => 'لا تكرر كلمات مرور من مواقع أخرى';

  @override
  String get warningEmptyNewPassword => 'يرجى إدخال كلمة مرور جديدة';

  @override
  String get resetFailed => 'فشل إعادة تعيين كلمة المرور';

  @override
  String get resetSuccessTitle => 'تمت إعادة التعيين\nبنجاح! 🎉';

  @override
  String get resetSuccessSubtitle =>
      'تم تغيير كلمة المرور الخاصة بك بنجاح.\nيمكنك الآن تسجيل الدخول بكلمة المرور الجديدة.';

  @override
  String get tipPrivatePassword => 'حافظ على سرية كلمة مرورك';

  @override
  String get tipChangeRegularly => 'قم بتغييرها كل 3-6 أشهر';

  @override
  String get tipSignOutUnknown => 'سجل الخروج من الأجهزة غير المعروفة';

  @override
  String get verificationSuccessTitle => 'تم التوثيق\nبنجاح! 🎉';

  @override
  String get verificationSuccessSubtitle => 'تم التحقق من هويتك بنجاح';

  @override
  String get identityVerified => 'الهوية موثقة';

  @override
  String get idConfirmed => 'تم تأكيد بطاقة الهوية';

  @override
  String get documentsApproved => 'المستندات مقبولة';

  @override
  String get documentsValid => 'جميع المستندات صالحة';

  @override
  String get accountSecured => 'الحساب مؤمن';

  @override
  String get accountProtected => 'حسابك محمي الآن';

  @override
  String get done => 'تم';

  @override
  String get whatYouCanDo => 'ما يمكنك فعله الآن';

  @override
  String get bookServices => 'حجز الخدمات الطبية';

  @override
  String get requestVisits => 'طلب زيارات منزلية';

  @override
  String get chatProviders => 'التحدث مع مقدمي الخدمة';

  @override
  String get accessHistory => 'الوصول لسجلك الطبي';

  @override
  String get continueToLogin => 'المتابعة لتسجيل الدخول';

  @override
  String get medicalHistoryTitle => 'السجل الطبي';

  @override
  String get skip => 'تخطي';

  @override
  String get stepInfo => 'البيانات';

  @override
  String get stepMedical => 'الطبي';

  @override
  String get stepId => 'الهوية';

  @override
  String get healthInfoTitle => 'المعلومات الصحية';

  @override
  String get healthInfoSubtitle => 'ساعدنا لتقديم رعاية أفضل لك';

  @override
  String get healthInfoSafetyDesc =>
      'تساعد هذه المعلومات فريقنا الطبي على الاستعداد بشكل أفضل لزياراتك وتضمن سلامتك.';

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
  String get noAllergies => 'ليس لدي أي حساسية معروفة';

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
  String get continueButton => 'متابعة';

  @override
  String get saveMedicalInfoError =>
      'تعذر حفظ المعلومات الطبية. يمكنك تحديثها لاحقاً.';

  @override
  String get diabetes => 'السكري';

  @override
  String get highBloodPressure => 'ضغط الدم المرتفع';

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
  String get thyroidDisorder => 'اضطرابات الغدة الدرقية';

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
  String get verifyIdentityTitle => 'توثيق هويتك';

  @override
  String get skipForNow => 'تخطي الآن';

  @override
  String get verifyIdentityDesc =>
      'كخدمة طبية مرخصة، نحتاج للتحقق من هويتك لضمان السلامة والثقة للجميع.';

  @override
  String get securePrivateTitle => 'آمن وخصوصي';

  @override
  String get securePrivateDesc => 'بياناتك مشفرة ومحمية بالكامل';

  @override
  String get quickProcessTitle => 'عملية سريعة';

  @override
  String get quickProcessDesc => 'التوثيق يستغرق أقل من دقيقتين';

  @override
  String get oneTimeOnlyTitle => 'لمرة واحدة فقط';

  @override
  String get oneTimeOnlyDesc => 'وثق مرة واحدة، واستخدم كل الخدمات';

  @override
  String get verifyNowButton => 'وثق الآن';

  @override
  String get doItLater => 'سأفعل هذا لاحقاً';

  @override
  String get idVerificationTitle => 'توثيق الهوية';

  @override
  String get scanFrontSide => 'مسح الوجه الأمامي';

  @override
  String get scanBackSide => 'مسح الوجه الخلفي';

  @override
  String stepXofY(Object current, Object total) {
    return 'خطوة $current من $total';
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
  String get keepWithinFrame => 'حافظ على البطاقة داخل الإطار';

  @override
  String get tipsForResults => 'نصائح لأفضل النتائج';

  @override
  String get goodLighting => 'تأكد من وجود إضاءة جيدة';

  @override
  String get flatAligned => 'ضع البطاقة بشكل مستوٍ ومحاذٍ';

  @override
  String get avoidBlur => 'تجنب الاهتزاز والانعكاسات';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get uploadGallery => 'رفع من المعرض';

  @override
  String get processingImage => 'جاري معالجة الصورة...';

  @override
  String get pleaseWait => 'يرجى الانتظار';

  @override
  String get uploadingDocs => 'جاري رفع المستندات...';

  @override
  String get securelySavingId => 'يتم حفظ هويتك بأمان';

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
  String get cameraError => 'فشل في فتح الكاميرا';

  @override
  String get galleryError => 'فشل في فتح المعرض';

  @override
  String get noImageError => 'لم يتم اختيار صورة';

  @override
  String get processImageError => 'فشل في معالجة الصورة';

  @override
  String uploadFailed(Object error) {
    return 'فشل الرفع: $error';
  }

  @override
  String get docsSubmittedTitle => 'تم إرسال المستندات!';

  @override
  String get docsSubmittedDesc =>
      'تم إرسال هويتك للمراجعة.\nسيقوم فريقنا بالتحقق منها قريباً.';

  @override
  String get pendingAdminReview => 'في انتظار مراجعة الإدارة';

  @override
  String get takes24to48Hours => 'يستغرق عادة من 24 إلى 48 ساعة';

  @override
  String get gotItContinue => 'فهمت، متابعة';

  @override
  String get reviewNotice => 'يمكنك البدء في استخدام التطبيق أثناء المراجعة';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navBookings => 'الحجوزات';

  @override
  String get navAI => 'المساعد الذكي';

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
  String get destinationFeeLabel => 'رسوم الانتقال';

  @override
  String get platformFeeLabel => 'رسوم المنصة';

  @override
  String get totalLabel => 'الإجمالي';

  @override
  String get visitReportTitle => 'تقرير الزيارة';

  @override
  String rateNurseTitle(Object nurseName) {
    return 'تقييم $nurseName';
  }

  @override
  String get ratingSubmittedTitle => 'تم إرسال التقييم';

  @override
  String get ratingPrompt => 'كيف كانت الخدمة المقدمة؟';

  @override
  String get ratingThanks => 'شكراً لتعليقاتك!';

  @override
  String get ratingSelectError => 'يرجى اختيار تقييم';

  @override
  String get reviewHint => 'اكتب مراجعة (اختياري)...';

  @override
  String get submitRating => 'إرسال التقييم';

  @override
  String get submitting => 'جاري الإرسال...';

  @override
  String get ratingThanksSnack => 'شكراً لتقييمك!';

  @override
  String get ratingSaved => 'تم حفظ التقييم بنجاح!';

  @override
  String get backToHome => 'العودة للرئيسية';

  @override
  String get currencyEgp => 'ج.م';

  @override
  String get defaultNurseName => 'ممرض';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodAfternoon => 'مساء الخير';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String get welcomeBack => 'مرحباً';

  @override
  String get searchPlaceholder => 'بماذا يمكننا مساعدتك؟';

  @override
  String get searchSemanticLabel =>
      'ابحث عن العيادات، الممرضين، أو استخدم المساعد الذكي';

  @override
  String get nursingService => 'خدمة تمريض';

  @override
  String get assigningNurse => 'جاري التعيين...';

  @override
  String get activeStatus => 'نشط';

  @override
  String get housepitalWallet => 'محفظة هاوسبيتال';

  @override
  String get availableBalance => 'الرصيد المتاح';

  @override
  String get topUp => 'شحن';

  @override
  String get history => 'السجل';

  @override
  String get bookNurse => 'احجز ممرض';

  @override
  String get homeCare => 'رعاية منزلية';

  @override
  String get findClinic => 'ابحث عن عيادة';

  @override
  String get bookVisits => 'احجز زيارة';

  @override
  String get aiHealthAssistant => 'المساعد الصحي الذكي';

  @override
  String get newLabel => 'جديد';

  @override
  String get aiAdviceSubtitle => 'احصل على استشارات صحية فورية';

  @override
  String get newsAndOffers => 'الأخبار والعروض';

  @override
  String get offer1Title => 'خصم 20% على الفحوصات العامة';

  @override
  String get offer1Subtitle => 'صالح حتى نهاية الشهر';

  @override
  String get offer2Title => 'استشارة أخصائي تغذية مجانية';

  @override
  String get offer2Subtitle => 'مع الاشتراك المميز';

  @override
  String get offer3Title => 'لقاحات الإنفلونزا متوفرة';

  @override
  String get offer3Subtitle => 'احجز زيارة منزلية الآن';

  @override
  String offerDetailsSnack(Object title) {
    return 'العرض: $title - التفاصيل قريباً';
  }
}
