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

  @override
  String get dependents => 'العائلة والتابعين';

  @override
  String get dependentsDesc => 'إدارة الملفات الشخصية لأفراد عائلتك';

  @override
  String get securitySection => 'الأمان';

  @override
  String get biometricLogin => 'تسجيل الدخول بالمؤشرات الحيوية';

  @override
  String get biometricLoginDesc => 'استخدم بصمة الإصبع أو الوجه لإلغاء القفل';

  @override
  String get biometricNotSupported =>
      'المؤشرات الحيوية غير مدعومة على هذا الجهاز';

  @override
  String get twoFactorAuth => 'التحقق بخطوتين';

  @override
  String get twoFactorAuthDesc => 'تأمين حسابك بخطوة تحقق إضافية';

  @override
  String get loginActivity => 'نشاط تسجيل الدخول';

  @override
  String get loginActivityDesc => 'مراقبة الجلسات والأجهزة النشطة';

  @override
  String get notificationsSection => 'الإشعارات';

  @override
  String get pushNotifications => 'إشعارات الهاتف';

  @override
  String get pushNotificationsDesc =>
      'تلقي التحديثات والتنبيهات في الوقت الفعلي على جهازك';

  @override
  String get emailNotifications => 'إشعارات البريد الإلكتروني';

  @override
  String get emailNotificationsDesc =>
      'الحصول على ملخصات وإيصالات مرسلة إلى بريدك الإلكتروني';

  @override
  String get smsUpdates => 'تحديثات الرسائل النصية';

  @override
  String get smsUpdatesDesc => 'تلقي تحديثات المواعيد عبر الرسائل النصية';

  @override
  String get appearanceSection => 'المظهر';

  @override
  String get dataSection => 'البيانات والخصوصية';

  @override
  String get clearCache => 'مسح التخزين المؤقت';

  @override
  String get clearCacheDesc => 'إخلاء مساحة تخزين عن طريق مسح الملفات المؤقتة';

  @override
  String get clearCacheConfirm =>
      'هل أنت متأكد من مسح التخزين المؤقت للتطبيق؟ سيؤدي ذلك إلى إخلاء مساحة مع الاحتفاظ بإعداداتك الشخصية.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get cacheCleared => 'تم مسح التخزين المؤقت بنجاح';

  @override
  String get clear => 'مسح';

  @override
  String get clearAiHistory => 'مسح سجل الذكاء الاصطناعي';

  @override
  String get clearAiHistoryDesc => 'حذف محادثات المساعد الذكي نهائياً';

  @override
  String get clearAiHistoryConfirm =>
      'هل أنت متأكد من مسح سجل المحادثات مع المساعد الصحي الذكي؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get aiHistoryCleared => 'تم مسح سجل المساعد الذكي بنجاح';

  @override
  String get downloadMyData => 'تحميل بياناتي';

  @override
  String get downloadMyDataDesc => 'طلب نسخة من بياناتك الشخصية';

  @override
  String get about => 'حول التطبيق';

  @override
  String get helpSupport => 'المساعدة والدعم';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get userLabel => 'المريض';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get signOutConfirmTitle => 'تسجيل الخروج';

  @override
  String get signOutConfirmDesc =>
      'هل أنت متأكد من رغبتك في تسجيل الخروج من حسابك؟';

  @override
  String get accountSection => 'الحساب';

  @override
  String get biometricConfirmIdentity => 'يرجى التحقق لتأكيد الهوية';

  @override
  String get biometricDisabled => 'تم تعطيل تسجيل الدخول البيومتري';

  @override
  String get biometricEnabledSuccess =>
      'تم تفعيل تسجيل الدخول البيومتري بنجاح!';

  @override
  String get biometricLoginRequired =>
      'المصادقة البيومترية مطلوبة لتفعيل هذه الميزة';

  @override
  String get myWallet => 'محفظتي';

  @override
  String get myWalletDesc => 'إدارة المدفوعات والبطاقات وسجل المعاملات';

  @override
  String get personalInfo => 'المعلومات الشخصية';

  @override
  String get personalInfoDesc => 'عرض وتعديل تفاصيل ملفك الشخصي';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterNursing => 'تمريض';

  @override
  String get filterClinic => 'عيادة';

  @override
  String get bookingsTitle => 'حجوزاتي';

  @override
  String get bookingsSubtitle => 'تتبع وإدارة مواعيدك الطبية';

  @override
  String get tabActive => 'نشط';

  @override
  String get tabHistory => 'سجل الحجوزات';

  @override
  String get familyTitle => 'عائلتي';

  @override
  String get addMember => 'إضافة فرد';

  @override
  String get addFamilyMember => 'إضافة فرد من العائلة';

  @override
  String get aboutFamilyTitle => 'حول أفراد العائلة';

  @override
  String get aboutFamilyDesc =>
      'أضف أفراد عائلتك لحجز خدمات التمريض لهم بسهولة. يمكنك تخزين معلوماتهم الطبية لسرعة الحجز.';

  @override
  String get gotIt => 'حسناً!';

  @override
  String get loadingFamily => 'جاري تحميل أفراد العائلة...';

  @override
  String get noFamilyMembers => 'لا يوجد أفراد عائلة بعد';

  @override
  String get noFamilyMembersDesc => 'أضف أحبائك لحجز خدمات التمريض لهم بسهولة';

  @override
  String get errLoadFamily =>
      'تعذر تحميل أفراد العائلة. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get years => 'سنوات';

  @override
  String get memberSingle => 'عضو واحد';

  @override
  String membersPlural(Object count) {
    return '$count أعضاء';
  }

  @override
  String get editFamilyMember => 'تعديل فرد من العائلة';

  @override
  String get deleteMember => 'حذف العضو';

  @override
  String deleteMemberConfirm(Object name) {
    return 'هل أنت متأكد من حذف $name؟';
  }

  @override
  String get actionUndone => 'لا يمكن التراجع عن هذا الإجراء';

  @override
  String get discardChangesTitle => 'تجاهل التغييرات؟';

  @override
  String get discardChangesDesc =>
      'لديك تغييرات غير محفوظة. هل أنت متأكد من المغادرة دون حفظ؟';

  @override
  String get keepEditing => 'مواصلة التعديل';

  @override
  String get discard => 'تجاهل';

  @override
  String get changesSaved => 'تم حفظ التغييرات!';

  @override
  String get familyMemberUpdated => 'تم تحديث معلومات فرد العائلة بنجاح.';

  @override
  String get relationship => 'الصلة';

  @override
  String get dateOfBirth => 'تاريخ الميلاد';

  @override
  String get gender => 'الجنس';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get nationalId => 'الرقم القومي';

  @override
  String get birthCertificateId => 'رقم شهادة الميلاد';

  @override
  String get chronicConditions => 'الأمراض المزمنة';

  @override
  String get allergies => 'الحساسية';

  @override
  String get addChronicCondition => 'إضافة مرض مزمن';

  @override
  String get addAllergy => 'إضافة حساسية';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get relationshipFather => 'أب';

  @override
  String get relationshipMother => 'أم';

  @override
  String get relationshipSon => 'ابن';

  @override
  String get relationshipDaughter => 'ابنة';

  @override
  String get relationshipBrother => 'أخ';

  @override
  String get relationshipSister => 'أخت';

  @override
  String get relationshipGrandparent => 'جد/جدة';

  @override
  String get relationshipGrandchild => 'حفيد/حفيدة';

  @override
  String get relationshipSpouse => 'زوج/زوجة';

  @override
  String get relationshipOther => 'آخر';

  @override
  String get savedAddressesTitle => 'العناوين المحفوظة';

  @override
  String get addressSavedSingle => 'تم حفظ عنوان واحد';

  @override
  String addressesSavedPlural(Object count) {
    return 'تم حفظ $count عناوين';
  }

  @override
  String get manageLocations => 'إدارة مواقع التوصيل الخاصة بك';

  @override
  String get loadingAddresses => 'جاري تحميل العناوين...';

  @override
  String get noSavedAddresses => 'لا توجد عناوين محفوظة';

  @override
  String get noSavedAddressesDesc =>
      'أضف عنوانك الأول للبدء في استخدام خدمات التمريض المنزلي';

  @override
  String get addFirstAddress => 'إضافة عنوانك الأول';

  @override
  String get addAddress => 'إضافة عنوان';

  @override
  String get aboutAddresses => 'حول العناوين';

  @override
  String get addressTypeHome => 'المنزل';

  @override
  String get addressTypeWork => 'العمل';

  @override
  String get addressTypeOther => 'أخرى';

  @override
  String get addressTypeHomeDesc => 'مكان إقامتك الرئيسي';

  @override
  String get addressTypeWorkDesc => 'عنوان مكان عملك';

  @override
  String get addressTypeOtherDesc => 'أي موقع آخر';

  @override
  String get defaultAddressNote => 'تعيين عنوان افتراضي لحجز أسرع';

  @override
  String get defaultTag => 'افتراضي';

  @override
  String get addressOptions => 'خيارات العنوان';

  @override
  String get setAsDefault => 'تعيين كافتراضي';

  @override
  String get editAddress => 'تعديل العنوان';

  @override
  String get deleteAddress => 'حذف العنوان';

  @override
  String get confirmDeleteAddress => 'هل أنت متأكد من حذف هذا العنوان؟';

  @override
  String get delete => 'حذف';

  @override
  String get addressDeleted => 'تم حذف العنوان بنجاح';

  @override
  String get addressSetDefault => 'تم تعيين العنوان كافتراضي بنجاح';

  @override
  String get errSetDefault => 'فشل في تعيين العنوان كافتراضي';

  @override
  String get errDeleteAddress => 'فشل في حذف العنوان';

  @override
  String get errLoadAddresses =>
      'تعذر تحميل العناوين. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get mapLocation => 'الموقع على الخريطة';

  @override
  String get locationNotSelected => 'الموقع غير حدد';

  @override
  String get locationSelected => 'تم تحديد الموقع';

  @override
  String get requiredForTracking => 'مطلوب لتتبع الممرض';

  @override
  String get pick => 'تحديد';

  @override
  String get change => 'تغيير';

  @override
  String get addressDetails => 'تفاصيل العنوان';

  @override
  String get labelOptional => 'تسمية (اختياري)';

  @override
  String get labelHint => 'مثال: المنزل، المكتب، بيت والدتي';

  @override
  String get streetAddress => 'اسم الشارع / العنوان';

  @override
  String get enterStreet => 'أدخل عنوان الشارع';

  @override
  String get areaDistrict => 'المنطقة / الحي';

  @override
  String get enterArea => 'أدخل المنطقة أو الحي';

  @override
  String get city => 'المدينة';

  @override
  String get enterCity => 'أدخل المدينة';

  @override
  String get state => 'المحافظة';

  @override
  String get enterState => 'أدخل المحافظة';

  @override
  String get zipCode => 'الرمز البريدي';

  @override
  String get enterZip => 'أدخل الرمز البريدي';

  @override
  String get preferences => 'التفضيلات';

  @override
  String get setDefaultAddress => 'تعيين كعنوان افتراضي';

  @override
  String get setDefaultAddressDesc => 'استخدم هذا العنوان افتراضياً للحجوزات';

  @override
  String get updateAddress => 'تحديث العنوان';

  @override
  String get addressUpdated => 'تم تحديث العنوان!';

  @override
  String get addressUpdatedDesc => 'تم تحديث عنوانك بنجاح.';

  @override
  String get pinLocationFirst => 'يرجى تحديد موقعك على الخريطة أولاً.';

  @override
  String get errLoadUserId =>
      'لم يتم العثور على معرف المستخدم. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get errUpdateAddress => 'فشل في تحديث العنوان';

  @override
  String get requiredField => 'مطلوب';

  @override
  String get warningUndone => 'هذا الإجراء لا يمكن التراجع عنه';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get basicInformation => 'معلومات أساسية';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get mobileNumberOptional => 'رقم الهاتف المحمول (اختياري)';

  @override
  String get identification => 'الهوية الشخصية';

  @override
  String get provideOneId => 'يرجى تقديم هوية واحدة على الأقل';

  @override
  String get medicalInformation => 'المعلومات الطبية';

  @override
  String get dangerZone => 'منطقة الخطر';

  @override
  String get deleteFamilyMemberDesc =>
      'احذف فرد العائلة هذا نهائيًا من حسابك. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get noChanges => 'لا توجد تغييرات';

  @override
  String noItemsAdded(Object title) {
    return 'لم يتم إضافة $title';
  }

  @override
  String get addChronicDiseaseHint => 'مثال: السكري، ضغط الدم';

  @override
  String get addAllergyHint => 'مثال: البنسلين، الفول السوداني';

  @override
  String get selectRelationshipWarn => 'يرجى اختيار صلة القرابة';

  @override
  String get selectDobWarn => 'يرجى اختيار تاريخ الميلاد';

  @override
  String get provideIdWarn => 'يرجى تقديم الرقم القومي أو رقم شهادة الميلاد';

  @override
  String get deleteMemberSuccess => 'تم حذف فرد العائلة بنجاح';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get add => 'إضافة';

  @override
  String get modified => 'معدل';

  @override
  String get deleteFamilyMember => 'حذف فرد العائلة';

  @override
  String get addressType => 'نوع العنوان';

  @override
  String get loadingBookings => 'جاري تحميل الحجوزات...';

  @override
  String get noActiveBookings => 'لا توجد حجوزات نشطة';

  @override
  String get noActiveBookingsDesc => 'ستظهر مواعيدك القادمة هنا';

  @override
  String get noBookingHistory => 'لا يوجد سجل حجوزات';

  @override
  String get noBookingHistoryDesc => 'ستظهر حجوزاتك المكتملة هنا';

  @override
  String get bookService => 'احجز خدمة';

  @override
  String get inProgress => 'قيد التنفيذ';

  @override
  String get inClinic => 'في العيادة';

  @override
  String get nurseArrived => 'وصلت الممرضة';

  @override
  String get readyForVisit => 'جاهز للزيارة';

  @override
  String get onTheWay => 'في الطريق';

  @override
  String get confirmed => 'تم التأكيد';

  @override
  String get awaitingConfirmation => 'بانتظار التأكيد';

  @override
  String get findingNurse => 'جاري البحث عن ممرضة';

  @override
  String get nurseOffersReady => 'عروض الممرضات جاهزة';

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get viewTicket => 'عرض التذكرة';

  @override
  String get track => 'تتبع';

  @override
  String get statusCancelled => 'ملغي';

  @override
  String get statusNoShow => 'عدم حضور';

  @override
  String get statusCompleted => 'مكتمل';

  @override
  String get rebook => 'إعادة حجز';

  @override
  String get nurseLabel => 'الممرض/ة';

  @override
  String get cancelBookingTitle => 'إلغاء الحجز؟';

  @override
  String cancelBookingLateDesc(Object fee) {
    return 'نظرًا لأنه تم تعيين الممرض/ة بالفعل، فسيتم تطبيق رسوم إلغاء متأخر بقيمة $fee جنيه مصري.';
  }

  @override
  String get cancelBookingNormalDesc =>
      'هل أنت متأكد من رغبتك في إلغاء هذا الحجز؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String lateCancellationFee(Object fee) {
    return 'رسوم الإلغاء المتأخر: $fee جنيه مصري';
  }

  @override
  String get goBack => 'العودة';

  @override
  String get cancelAndPayFee => 'إلغاء ودفع الرسوم';

  @override
  String get yesCancel => 'نعم، إلغاء';

  @override
  String get bookingCancelled => 'تم إلغاء الحجز';

  @override
  String get matchingRequestCancelled => 'تم إلغاء طلب المطابقة';

  @override
  String get failedToCancelMatching => 'فشل إلغاء طلب المطابقة';

  @override
  String get queueLabel => 'طابور';

  @override
  String get digitalTicket => 'تذكرة رقمية';

  @override
  String get scanAtReception => 'امسح عند الاستقبال';

  @override
  String get checkInPin => 'رمز تسجيل الوصول';

  @override
  String get patientLabel => 'المريض';

  @override
  String get clinicLabel => 'العيادة';

  @override
  String get addressLabel => 'العنوان';

  @override
  String get doctorLabel => 'الطبيب';

  @override
  String get timeLabel => 'الوقت';

  @override
  String get ticketInstruction =>
      'قم بعرض رمز QR هذا أو الرمز عند استقبال العيادة لتسجيل الوصول.';

  @override
  String get close => 'إغلاق';

  @override
  String get estArrival => 'الوصول المتوقع';

  @override
  String get distance => 'المسافة';

  @override
  String get youLabel => 'أنت';

  @override
  String get visitStartCode => 'رمز بدء الزيارة';

  @override
  String get provideStartCodeDesc => 'قدم هذا الرمز للممرض/ة لبدء الجلسة.';

  @override
  String get serviceInProgress => 'الخدمة قيد التنفيذ';

  @override
  String serviceInProgressDesc(Object serviceName) {
    return 'يقوم الممرض/ة بتقديم $serviceName. سيتم وضع علامة اكتمال على الزيارة قريبًا.';
  }

  @override
  String get newTag => 'جديد';

  @override
  String get registeredNurse => 'ممرض/ة مسجل/ة';

  @override
  String callingNurse(Object phone) {
    return 'جاري الاتصال بـ $phone...';
  }

  @override
  String get callingEmergency => 'جاري الاتصال بخدمات الطوارئ...';

  @override
  String get sosLabel => 'استغاثة';

  @override
  String get filingReport => 'جاري تقديم بلاغ...';

  @override
  String get reportLabel => 'إبلاغ';

  @override
  String get nurseAssigned => 'تم تعيين ممرض/ة';

  @override
  String get nurseOnTheWay => 'الممرض/ة في الطريق';

  @override
  String get nurseHasArrived => 'وصلت الممرضة';

  @override
  String get serviceInProgressLabel => 'الخدمة قيد التنفيذ';

  @override
  String get waitingNurseDesc => 'في انتظار توجه الممرض/ة إلى موقعك.';

  @override
  String get nurseHeadingDesc => 'الممرض/ة يتوجه إلى موقعك الآن.';

  @override
  String get nurseOutsideDesc => 'الممرض/ة بالخارج. يرجى تقديم رمز البدء.';

  @override
  String get nurseProvidingDesc => 'الممرض/ة يقوم بتقديم الخدمة حاليًا.';

  @override
  String get trackingDesc => 'نحن نتتبع موعدك.';

  @override
  String get trackingTitle => 'تتبع';

  @override
  String get unitMinutes => 'دقيقة';

  @override
  String get unitHours => 'ساعة';

  @override
  String get unitMeters => 'متر';

  @override
  String get unitKilometers => 'كم';

  @override
  String get categoryAll => 'الكل';

  @override
  String get categoryPopular => 'شائع';

  @override
  String get categoryQuick => 'سريع';

  @override
  String get categorySpecialized => 'متخصص';

  @override
  String get categoryLongTerm => 'طويل الأمد';

  @override
  String get serviceWoundCareTitle => 'العناية بالجروح';

  @override
  String get serviceWoundCareDuration => '30-45 دقيقة';

  @override
  String get serviceWoundCareDesc =>
      'خدمات احترافية للعناية بالجروح وتغيير الضمادات مقدمة من ممرضين معتمدين.';

  @override
  String get serviceWoundCareInc1 => 'تقييم احترافي للجرح';

  @override
  String get serviceWoundCareInc2 => 'ضماد معقم';

  @override
  String get serviceWoundCareInc3 => 'تنظيف الجرح';

  @override
  String get serviceWoundCareInc4 => 'زيارات متابعة';

  @override
  String get serviceWoundCareInc5 => 'مراقبة التقدم';

  @override
  String get serviceInjectionsTitle => 'الحقن';

  @override
  String get serviceInjectionsDuration => '15-20 دقيقة';

  @override
  String get serviceInjectionsDesc => 'خدمات حقن آمنة وغير مؤلمة في منزلك.';

  @override
  String get serviceInjectionsInc1 => 'جميع أنواع الحقن';

  @override
  String get serviceInjectionsInc2 => 'تعقيم مناسب';

  @override
  String get serviceInjectionsInc3 => 'إعطاء الدواء';

  @override
  String get serviceInjectionsInc4 => 'الرعاية بعد الحقن';

  @override
  String get serviceElderlyCareTitle => 'رعاية كبار السن';

  @override
  String get serviceElderlyCareDuration => '1-4 ساعات';

  @override
  String get serviceElderlyCareDesc =>
      'رعاية شاملة لكبار السن تشمل المساعدة في الأنشطة اليومية.';

  @override
  String get serviceElderlyCareInc1 => 'المساعدة في الأنشطة اليومية';

  @override
  String get serviceElderlyCareInc2 => 'إدارة الأدوية';

  @override
  String get serviceElderlyCareInc3 => 'مراقبة العلامات الحيوية';

  @override
  String get serviceElderlyCareInc4 => 'المرافقة والدعم المعنوي';

  @override
  String get servicePostOpCareTitle => 'رعاية ما بعد الجراحة';

  @override
  String get servicePostOpCareDuration => '45-60 دقيقة';

  @override
  String get servicePostOpCareDesc =>
      'خدمات رعاية ما بعد الجراحة لضمان الشفاء السلس بعد العملية.';

  @override
  String get servicePostOpCareInc1 => 'العناية بجروح العمليات';

  @override
  String get servicePostOpCareInc2 => 'التحكم في الألم';

  @override
  String get servicePostOpCareInc3 => 'إعطاء الأدوية';

  @override
  String get servicePostOpCareInc4 => 'مراقبة العلامات الحيوية';

  @override
  String get serviceBabyCareTitle => 'رعاية الأطفال الرضع';

  @override
  String get serviceBabyCareDuration => '2-3 ساعات';

  @override
  String get serviceBabyCareDesc =>
      'خدمات رعاية احترافية لحديثي الولادة والرضع.';

  @override
  String get serviceBabyCareInc1 => 'متابعة حديثي الولادة';

  @override
  String get serviceBabyCareInc2 => 'المساعدة في الرضاعة والتغذية';

  @override
  String get serviceBabyCareInc3 => 'الاستحمام والنظافة';

  @override
  String get serviceBabyCareInc4 => 'تقييم التطور والنمو';

  @override
  String get serviceIvTherapyTitle => 'العلاج بالمحاليل الوريدية';

  @override
  String get serviceIvTherapyDuration => '45-60 دقيقة';

  @override
  String get serviceIvTherapyDesc => 'إعطاء الأدوية والمحاليل عن طريق الوريد';

  @override
  String get serviceIvTherapyInc1 => 'تركيب الكانيولا الوريدية';

  @override
  String get serviceIvTherapyInc2 => 'إعطاء الأدوية';

  @override
  String get serviceIvTherapyInc3 => 'العلاج بالسوائل';

  @override
  String get serviceIvTherapyInc4 => 'المراقبة والمتابعة';

  @override
  String get serviceCatheterCareTitle => 'رعاية القسطرة';

  @override
  String get serviceCatheterCareDuration => '30-40 دقيقة';

  @override
  String get serviceCatheterCareDesc =>
      'خدمات احترافية لتركيب وصيانة ورعاية القسطرة.';

  @override
  String get serviceCatheterCareInc1 => 'تركيب القسطرة';

  @override
  String get serviceCatheterCareInc2 => 'الصيانة الدورية';

  @override
  String get serviceCatheterCareInc3 => 'الوقاية من الالتهابات';

  @override
  String get serviceCatheterCareInc4 => 'توجيه وتعليم المريض';

  @override
  String get serviceVitalSignsTitle => 'قياس العلامات الحيوية';

  @override
  String get serviceVitalSignsDuration => '20-30 دقيقة';

  @override
  String get serviceVitalSignsDesc =>
      'مراقبة كاملة للعلامات الحيوية مع تقديم تقارير مفصلة.';

  @override
  String get serviceVitalSignsInc1 => 'ضغط الدم';

  @override
  String get serviceVitalSignsInc2 => 'درجة الحرارة';

  @override
  String get serviceVitalSignsInc3 => 'ضربات القلب';

  @override
  String get serviceVitalSignsInc4 => 'نسبة الأكسجين بالدم';

  @override
  String get serviceVitalSignsInc5 => 'تقرير صحي مفصل';

  @override
  String get serviceBloodDrawTitle => 'سحب عينات الدم';

  @override
  String get serviceBloodDrawDuration => '15 دقيقة';

  @override
  String get serviceBloodDrawDesc => 'سحب عينات الدم بشكل احترافي من المنزل.';

  @override
  String get serviceBloodDrawInc1 => 'جمع عينات الدم';

  @override
  String get serviceBloodDrawInc2 => 'التسمية والترميز الصحيح';

  @override
  String get serviceBloodDrawInc3 => 'التوصيل للمختبر';

  @override
  String get serviceBloodDrawInc4 => 'تنسيق واستلام النتائج';

  @override
  String get servicePhysiotherapyTitle => 'العلاج الطبيعي';

  @override
  String get servicePhysiotherapyDuration => '60-90 دقيقة';

  @override
  String get servicePhysiotherapyDesc =>
      'جلسات علاج طبيعي منزلي لإعادة التأهيل وتحسين الحركة.';

  @override
  String get servicePhysiotherapyInc1 => 'تقييم الحالة';

  @override
  String get servicePhysiotherapyInc2 => 'التمارين العلاجية';

  @override
  String get servicePhysiotherapyInc3 => 'التدريب على الحركة';

  @override
  String get servicePhysiotherapyInc4 => 'متابعة التقدم والتحسن';

  @override
  String get categoryAllServices => 'كل الخدمات';

  @override
  String get categoryPostSurgery => 'بعد الجراحة';

  @override
  String get categoryElderlyCare => 'رعاية كبار السن';

  @override
  String get categoryInjections => 'الحقن';

  @override
  String get categoryWoundCare => 'العناية بالجروح';

  @override
  String get categoryOrthopedic => 'العظام';

  @override
  String get servicePostSurgicalCareTitle => 'رعاية ما بعد الجراحة';

  @override
  String get servicePostSurgicalCareDesc =>
      'رعاية تمريضية احترافية للمرضى المتعافين من العمليات الجراحية';

  @override
  String get servicePostSurgicalCareDuration => '2-3 ساعات';

  @override
  String get servicePostSurgicalCareInc1 => 'غيار ورعاية الجروح';

  @override
  String get servicePostSurgicalCareInc2 => 'المساعدة في التحكم في الألم';

  @override
  String get servicePostSurgicalCareInc3 => 'مراقبة العلامات الحيوية';

  @override
  String get servicePostSurgicalCareInc4 => 'إعطاء الأدوية';

  @override
  String get servicePostSurgicalCareInc5 => 'إرشاد لتمارين ما بعد الجراحة';

  @override
  String get servicePostSurgicalCareInc6 => 'إجراءات الوقاية من العدوى';

  @override
  String get serviceChronicDiseaseTitle => 'إدارة الأمراض المزمنة';

  @override
  String get serviceChronicDiseaseDesc =>
      'رعاية مستمرة لمرضى السكري والضغط وغيرها';

  @override
  String get serviceChronicDiseaseDuration => '2-3 ساعات';

  @override
  String get serviceChronicDiseaseInc1 => 'مراقبة نسبة السكر في الدم';

  @override
  String get serviceChronicDiseaseInc2 => 'فحص ضغط الدم';

  @override
  String get serviceChronicDiseaseInc3 => 'إدارة الأدوية';

  @override
  String get serviceChronicDiseaseInc4 => 'تقديم النصائح الغذائية';

  @override
  String get serviceChronicDiseaseInc5 => 'إرشادات التمارين الرياضية';

  @override
  String get serviceChronicDiseaseInc6 => 'التوعية والتثقيف الصحي';

  @override
  String get serviceIvTherapyDurationShort => '30-60 دقيقة';

  @override
  String get serviceIvTherapyInc5 => 'الرعاية بعد الإجراء';

  @override
  String get serviceImScInjectionsTitle => 'الحقن العضلي/تحت الجلد';

  @override
  String get serviceImScInjectionsDesc => 'إعطاء الحقن العضلية وتحت الجلد';

  @override
  String get serviceImScInjectionsDuration => '15-20 دقيقة';

  @override
  String get serviceImScInjectionsInc1 => 'إعطاء الحقنة';

  @override
  String get serviceImScInjectionsInc2 => 'تجهيز وتعقيم موقع الحقن';

  @override
  String get serviceImScInjectionsInc3 => 'المراقبة بعد الحقن';

  @override
  String get serviceImScInjectionsInc4 => 'التخلص الآمن من المستلزمات الطبية';

  @override
  String get serviceWoundDressingTitle => 'غيار الجروح';

  @override
  String get serviceWoundDressingDesc => 'تنظيف وتضميد الجروح بشكل احترافي';

  @override
  String get serviceWoundDressingDuration => '30-45 دقيقة';

  @override
  String get serviceWoundDressingInc1 => 'تقييم الجرح';

  @override
  String get serviceWoundDressingInc2 => 'التنظيف والتطهير';

  @override
  String get serviceWoundDressingInc3 => 'وضع ضمادة معقمة';

  @override
  String get serviceWoundDressingInc4 => 'متابعة أعراض الالتهاب والعدوى';

  @override
  String get serviceWoundDressingInc5 => 'تعليمات العناية بالجرح';

  @override
  String get serviceBurnCareTitle => 'العناية بالحروق';

  @override
  String get serviceBurnCareDesc => 'رعاية متخصصة لإصابات الحروق';

  @override
  String get serviceBurnCareDuration => '45-60 دقيقة';

  @override
  String get serviceBurnCareInc1 => 'تقييم الحرق';

  @override
  String get serviceBurnCareInc2 => 'تنظيف الجرح الحروق';

  @override
  String get serviceBurnCareInc3 => 'ضماد متخصص للحروق';

  @override
  String get serviceBurnCareInc4 => 'التحكم في الألم';

  @override
  String get serviceBurnCareInc5 => 'متابعة شفاء الجرح';

  @override
  String get serviceFractureCareTitle => 'العناية بالكسور';

  @override
  String get serviceFractureCareDesc =>
      'رعاية المرضى الذين يعانون من كسور العظام';

  @override
  String get serviceFractureCareDuration => '1-2 ساعة';

  @override
  String get serviceFractureCareInc1 => 'تعليمات العناية بالجبيرة';

  @override
  String get serviceFractureCareInc2 => 'التحكم والتعامل مع الألم';

  @override
  String get serviceFractureCareInc3 => 'المساعدة في الحركة';

  @override
  String get serviceFractureCareInc4 => 'تمارين العلاج الطبيعي';

  @override
  String get serviceFractureCareInc5 => 'متابعة التورم والانتفاخ';

  @override
  String get filterServices => 'تصفية الخدمات';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get sortBy => 'ترتيب حسب';

  @override
  String get sortRecommended => 'موصى به';

  @override
  String get sortPriceLowToHigh => 'السعر: من الأقل للأعلى';

  @override
  String get sortPriceHighToLow => 'السعر: من الأعلى للأقل';

  @override
  String get sortHighestRated => 'الأعلى تقييماً';

  @override
  String get applyFilters => 'تطبيق التصفية';

  @override
  String get nursingServicesHeader => 'الخدمات\nالتمريضية';

  @override
  String nursingServicesSubtitle(Object count) {
    return 'اكتشف $count من العلاجات الفاخرة بالمنزل.';
  }

  @override
  String get searchTreatments => 'ابحث عن العلاجات...';

  @override
  String get noServicesFound => 'لم يتم العثور على خدمات';

  @override
  String get tryDifferentSearch => 'حاول البحث بكلمة مختلفة أو فئة أخرى';

  @override
  String priceEgp(Object price) {
    return '$price ج.م';
  }

  @override
  String get ourServices => 'خدماتنا';

  @override
  String get servicesSubtitle => 'رعاية صحية احترافية عند باب منزلك';

  @override
  String get searchServices => 'ابحث عن الخدمات...';

  @override
  String get popularServices => '🔥 الخدمات الشائعة';

  @override
  String get allServices => '📋 كل الخدمات';

  @override
  String get popularLabel => 'شائع';

  @override
  String get tryAdjustingFilters => 'حاول تعديل البحث أو التصفية';

  @override
  String get clearFilters => 'مسح التصفية';

  @override
  String get shareComingSoon => 'ميزة المشاركة ستتوفر قريباً!';

  @override
  String get professionalService => 'خدمة احترافية';

  @override
  String reviewsCount(Object count) {
    return '$count تقييم';
  }

  @override
  String bookingsCount(Object count) {
    return '$count حجز';
  }

  @override
  String get price => 'السعر';

  @override
  String get duration => 'المدة';

  @override
  String get response => 'الاستجابة';

  @override
  String get lessThan5Min => 'أقل من 5 دقائق';

  @override
  String get highlightCertified => 'معتمد';

  @override
  String get highlightCertifiedDesc => 'ممرضون مرخصون';

  @override
  String get highlightOnTime => 'في الوقت';

  @override
  String get highlightOnTimeDesc => '98% التزام بالمواعيد';

  @override
  String get highlightTrusted => 'موثوق';

  @override
  String get highlightTrustedDesc => 'أكثر من 5.2 ألف عميل';

  @override
  String get highlightSupport => '24/7';

  @override
  String get highlightSupportDesc => 'الدعم';

  @override
  String get tabIncludes => 'يشمل';

  @override
  String get tabReviews => 'التقييمات';

  @override
  String get tabFaq => 'الأسئلة الشائعة';

  @override
  String get whatsIncluded => 'ماذا تشمل الخدمة';

  @override
  String get review1Name => 'أحمد م.';

  @override
  String get review1Comment => 'خدمة ممتازة! الممرض كان محترفاً للغاية.';

  @override
  String get review2Name => 'فاطمة ك.';

  @override
  String get review2Comment => 'راضية جداً عن الرعاية المقدمة. أوصي به بشدة!';

  @override
  String get review3Name => 'محمد س.';

  @override
  String get review3Comment => 'خدمة جيدة، الممرض وصل في الوقت المحدد.';

  @override
  String get timeAgo2Days => 'منذ يومين';

  @override
  String get timeAgo1Week => 'منذ أسبوع';

  @override
  String get timeAgo2Weeks => 'منذ أسبوعين';

  @override
  String get faq1Q => 'كيف أستعد للخدمة؟';

  @override
  String get faq1A =>
      'تأكد من توفير مساحة نظيفة ومريحة للممرض للعمل. جهز أي وثائق طبية ذات صلة.';

  @override
  String get faq2Q => 'هل يمكنني إعادة جدولة حجزي؟';

  @override
  String get faq2A => 'نعم، يمكنك إعادة الجدولة حتى ساعتين قبل موعدك مجاناً.';

  @override
  String get faq3Q => 'ماذا لو احتجت إلى الإلغاء؟';

  @override
  String get faq3A =>
      'الإلغاء قبل ساعتين أو أكثر مجاني. قد يترتب على الإلغاء المتأخر رسوم بسيطة.';

  @override
  String get verifiedNursesOnly => 'ممرضون معتمدون فقط';

  @override
  String get verifiedNursesDesc =>
      'جميع الممرضين مرخصين، وتم فحص خلفياتهم، وحاصلين على تقييمات عالية من المرضى.';

  @override
  String get satisfactionGuarantee => 'ضمان الرضا';

  @override
  String get satisfactionGuaranteeDesc =>
      'ضمان استرداد الأموال 100% إذا لم تكن راضياً';

  @override
  String get freeReschedule => 'جدولة مجانية';

  @override
  String get easyRefund => 'استرداد سهل';

  @override
  String get support247 => 'دعم 24/7';

  @override
  String get totalPrice => 'السعر الإجمالي';

  @override
  String get perVisit => '/زيارة';

  @override
  String get bookNow => 'احجز الآن';

  @override
  String get serviceUnavailable =>
      'الخدمة غير متوفرة حالياً. يرجى تجربة خدمة أخرى.';
}
