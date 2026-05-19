# خطة دعم اللغتين (العربية والإنجليزية) وتفعيل نظام الـ RTL في تطبيق Housepital

تهدف هذه الخطة إلى تحويل التطبيق ليدعم اللغة العربية والإنجليزية بشكل كامل، بالإضافة إلى تهيئة واجهة المستخدم (UI/UX) لتدعم الاتجاهين (من اليمين لليسار RTL، ومن اليسار لليمين LTR).

---

## ✅ حالة الإنجاز (Progress Status)
- [x] **المرحلة الأولى: البنية التحتية** (LocaleProvider, main.dart integration).
- [x] **المرحلة الثانية: ملفات الترجمة** (ARB files structure).
- [ ] **المرحلة الثالثة: تعديل الشاشات** (جاري العمل عليها).
  - [x] شاشات البداية (Splash & Onboarding).
  - [x] مسار الدخول (Auth Flow - Login, Register, Forgot Password, OTP, Medical History, Identity).
  - [ ] الشاشة الرئيسية (Home).
  - [ ] صفحة الملف الشخصي (Profile).
  - [ ] مسار الحجز (Booking Flow).
- [ ] **المرحلة الرابعة: المميزات الإضافية** (Chatbot, Notifications).

---

## 🛠️ المرحلة الأولى: البنية التحتية لإدارة اللغة (Infrastructure)
... (بقية المحتوى كما هو) ...


### 4. مسار الحجز (Booking Flow)
- `booking_step1_select_patient.dart` (اختيار المريض).
- `booking_step2_select_service.dart` (تحديد الخدمة / القسم).
- `booking_step3_select_time.dart` (الموعد والطبيب).
- `booking_step4_confirmation.dart` (ملخص وتأكيد الحجز).

---

## 🤖 المرحلة الرابعة: باقي المميزات (Chatbot & Notifications)
1. **شاشة الإشعارات (Notifications)**: 
   - ضبط اتجاه أيقونة الإشعار والوقت.
2. **شاشة الشات (Chatbot)**:
   - التأكد من أن فقاعة رسائل المستخدم تظهر جهة البداية (Start) حسب اللغة وفقاعة الشات بوت تظهر في الجهة الأخرى.

---

## 💡 قواعد وملاحظات هامة لتعديل الكود (Cheat Sheet)
دائماً استبدل عناصر الاتجاه الثابتة بعناصر تعتمد على اتجاه الشاشة:
- `EdgeInsets.only(left: 10)` ⬅️ تُستبدل بـ `EdgeInsetsDirectional.only(start: 10)`
- `Alignment.topLeft` ⬅️ تُستبدل بـ `AlignmentDirectional.topStart`
- `Positioned(left: 20)` ⬅️ تُستبدل بـ `Positioned.directional(textDirection: Directionality.of(context), start: 20)`
- `BorderRadius.only(topLeft: ...)` ⬅️ تُستبدل بـ `BorderRadiusDirectional.only(topStart: ...)`