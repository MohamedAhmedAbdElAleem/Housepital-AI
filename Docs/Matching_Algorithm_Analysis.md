# 🔍 تحليل شامل ومتحقق: Matching Algorithm — ايه اتعمل وايه لسه

> **تم التحقق من كل سطر ضد الكود الفعلى فى البروجكت**
> آخر تحديث: 2026-04-20

---

## 📊 ملخص سريع — الحالة الحقيقية

| المكون | Backend | Patient App | Nurse App |
|--------|:-------:|:-----------:|:---------:|
| **اختيار الخدمة** | ✅ | ✅ | — |
| **Price Estimate** | ✅ | ✅ | — |
| **اختيار المريض + التفاصيل** | ✅ | ✅ | — |
| **انشاء Matching Request** | ✅ | ✅ | — |
| **Phase 1: GeoSpatial Filter** | ✅ | — | — |
| **Phase 2: Weighted Scoring** | ✅ | — | — |
| **Phase 3: Sort & Limit Top 5** | ✅ | — | — |
| **Phase 4: Create Offers** | ✅ | — | — |
| **Socket: إشعار الممرض بعرض جديد** | ✅ | — | ✅ |
| **الممرض يقبل/يرفض** | ✅ | — | ✅ |
| **Socket: إشعار المريض بعرض جديد** | ✅ | ✅ | — |
| **عرض العروض للمريض** | ✅ | ✅ | — |
| **المريض يقبل ممرض** | ✅ | ✅ | — |
| **انشاء Booking + PIN** | ✅ | ✅ | — |
| **Socket: تأكيد الحجز** | ✅ | ✅ | ✅ |
| **رفض العروض التانية** | ✅ | — | ✅ |
| **الغاء Matching Request** | ✅ | ✅ | — |
| **Request Expiry (10 دقايق)** | ✅ | ✅ | — |
| **Nurse Location Update (Socket)** | ✅ | — | ✅ |
| **التتبع (GPS + Map + OSRM)** | ✅ | ⚠️ استاتيك | ✅ فعلى |
| **Status: On-the-way** | ✅ | ⚠️ عرض فقط | ✅ |
| **Status: Arrived** | ✅ | ⚠️ عرض فقط | ✅ |
| **عرض الـ PIN للمريض** | ✅ | ✅ موجود! | — |
| **PIN Verification → بدء الزيارة** | ✅ | — | ✅ |
| **Visit Report + إنهاء الزيارة** | ✅ endpoint | ❌ | ❌ **مفيش UI** |
| **الفاتورة + التقييم (UI فقط)** | ⚠️ | ✅ **shell موجود (hardcoded)** | ❌ |
| **Wallet + Commission Deduction** | ✅ كامل | — | ✅ **صفحة كاملة** |
| **PayMob Payment (Recharge)** | ✅ كامل | — | ✅ **Card + Mobile Wallet** |
| **التقييم المتبادل Backend** | ⚠️ Model فقط | ❌ API call | ❌ |
| **الدفع المباشر للخدمة** | ❌ | ❌ | ❌ |
| **الغاء متأخر + تعويض** | ❌ | ❌ | ❌ |
| **No-Show** | ❌ | ❌ | ❌ |
| **Nurse Emergency Cancel** | ❌ | ❌ | ❌ |

---

## 📖 تفصيل كل مرحلة

---

### 🟢 مرحلة 1: اختيار الخدمة (Customer App)

> **Scenario 6:** المريض يفتح صفحة الخدمات → يختار خدمة → يضغط "Request Service"

| ايه | فين | الحالة |
|-----|-----|--------|
| صفحة الخدمات (categories + list) | [services_page.dart](file:///f:/Housepital-AI/Housepital-AI/housepital/lib/features/customer/services/presentation/pages/services_page.dart) | ✅ |
| تفاصيل الخدمة + زر Request | [service_details_page.dart](file:///f:/Housepital-AI/Housepital-AI/housepital/lib/features/customer/services/presentation/pages/service_details_page.dart) | ✅ |

---

### 🟢 مرحلة 2: Price Estimate

> **Docs:** `POST /api/matching/price-estimate` — تقدير السعر قبل الطلب

| ايه | فين | الحالة |
|-----|-----|--------|
| API: Price Estimate endpoint | [matchingController.js](file:///f:/Housepital-AI/Housepital-AI/Backend/src/controllers/matchingController.js) | ✅ |
| Pricing logic (Haversine + fees) | [pricingService.js](file:///f:/Housepital-AI/Housepital-AI/Backend/src/services/pricingService.js) | ✅ |
| Flutter call to price-estimate | [booking_step1_select_patient.dart](file:///f:/Housepital-AI/Housepital-AI/housepital/lib/features/customer/booking/presentation/pages/booking_step1_select_patient.dart) | ✅ |

---

### 🟢 مرحلة 3: اختيار المريض + التفاصيل (Customer App)

> **Scenarios 7-9:** اختيار المستفيد → المعدات → الوقت → الجنس → الملاحظات → "Find Nurse"

| ايه | فين | الحالة |
|-----|-----|--------|
| اختيار المريض (Self / Dependent) | [booking_step1_select_patient.dart](file:///f:/Housepital-AI/Housepital-AI/housepital/lib/features/customer/booking/presentation/pages/booking_step1_select_patient.dart) | ✅ |
| تفضيل الجنس + الوقت + الملاحظات | نفس الملف | ✅ |
| Equipment deposit flow | `Booking.js` عنده `hasMedicalTools + toolsDeposit` fields | ❌ **مش متنفذ فى الـ UI** |
| Prescription upload | `Booking.js` عنده `prescriptionUrl` field | ❌ **مش متنفذ فى الـ UI** |
| ارسال Matching Request | `booking_step1 → POST /api/matching/request` | ✅ |

---

### 🟢 مرحلة 4: الخوارزمية (Backend — 4 Phases) ✅ كامل

> **Docs Section 3:** الخوارزمية بتشتغل فى 4 مراحل — **كل الـ 4 متنفذة بالكامل**

#### Phase 1: Geospatial Filter
| ايه | فين |
|-----|-----|
| MongoDB `$geoNear` query | [matchingService.js](file:///f:/Housepital-AI/Housepital-AI/Backend/src/services/matchingService.js) |
| Filters: isOnline + verified + gender + skills | نفس الملف |
| **اضافة فوق الدوكومنت:** Radius expansion (15→1000km) | نفس الملف |
| **اضافة فوق الدوكومنت:** Search both currentLocation + workZone | نفس الملف |

#### Phase 2: Weighted Scoring
| Factor | Weight | الحالة |
|--------|--------|--------|
| Distance | 35% | ✅ |
| Rating | 25% | ✅ |
| Experience | 15% | ✅ |
| Completion Rate | 15% | ✅ |
| Response Time | 10% | ✅ |

#### Phase 3: Sort & Select Top N  →  ✅
#### Phase 4: Create Offers + Socket.io + 60s Timer  →  ✅

---

### 🟢 مرحلة 5: الممرض يستقبل العرض ويرد (Nurse App)

> **Scenario 26:** عرض يوصل للممرض ← 60 ثانية ← Accept/Reject

| ايه | فين | الحالة |
|-----|-----|--------|
| Socket: `matching:new_offer` listener | [nurse_home_page.dart](file:///f:/Housepital-AI/Housepital-AI/housepital_staff/lib/features/nurse/presentation/pages/nurse_home_page.dart) | ✅ |
| Fetch pending offers API | [nurse_booking_cubit.dart](file:///f:/Housepital-AI/Housepital-AI/housepital_staff/lib/features/nurse/presentation/cubit/nurse_booking_cubit.dart) → `GET /matching/nurse-offers` | ✅ |
| Accept/Decline offer | نفس الملف → `PUT /matching/nurse-offers/:id/respond` | ✅ |
| Backend: handleNurseResponse + expiry check + update avg response time | [matchingService.js](file:///f:/Housepital-AI/Housepital-AI/Backend/src/services/matchingService.js) | ✅ |

---

### 🟢 مرحلة 6: المريض يشوف العروض ويختار (Customer App)

> **Docs:** المريض يشوف لحد 5 عروض ← يختار واحد

| ايه | فين | الحالة |
|-----|-----|--------|
| Socket: `matching:nurse_offer_available` | [booking_matching_screen.dart](file:///f:/Housepital-AI/Housepital-AI/housepital/lib/features/customer/booking/presentation/pages/booking_matching_screen.dart) | ✅ |
| Fetch offers: `GET /patient-offers/:id` | نفس الملف | ✅ |
| Show nurse cards (name, photo, rating, price, ETA) | نفس الملف | ✅ |
| Accept nurse: `PUT /patient-offers/:id/respond` | نفس الملف | ✅ |
| Matching search screen with animation | نفس الملف | ✅ |

---

### 🟢 مرحلة 7: انشاء الحجز (Backend)

> **Docs:** لما المريض يقبل ← Booking + PIN + Transaction + الغاء باقى العروض

| ايه | فين | الحالة |
|-----|-----|--------|
| Create Booking with visit PIN | [matchingService.js](file:///f:/Housepital-AI/Housepital-AI/Backend/src/services/matchingService.js) | ✅ |
| Platform fee Transaction | نفس الملف | ✅ |
| Cancel other offers + notify | نفس الملف | ✅ |
| Socket: `matching:booking_confirmed` (both sides) | نفس الملف | ✅ |

---

### 🟡 مرحلة 8: التتبع — الممرض فى الطريق

> **Scenario 11:** المريض يشوف الممرض على الخريطة + ETA

| ايه | فين | الحالة |
|-----|-----|--------|
| **Nurse:** Tracking page (real map + OSRM routing) | [nurse_tracking_page.dart](file:///f:/Housepital-AI/Housepital-AI/housepital_staff/lib/features/nurse/presentation/pages/nurse_tracking_page.dart) | ✅ **كامل** |
| **Nurse:** Status buttons: assigned → on-the-way → arrived | نفس الملف L490-535 | ✅ |
| **Nurse:** Live GPS tracking (stream + 5s timer) | نفس الملف L55-89 | ✅ |
| **Nurse:** OSRM Route + Distance + ETA | نفس الملف L151-176 | ✅ |
| **Nurse:** Update location on server per 5s | نفس الملف L92-110 | ✅ |
| **Nurse:** Call patient button | نفس الملف L443-474 | ✅ |
| Backend: updateNurseLocation API | [bookingController.js](file:///f:/Housepital-AI/Housepital-AI/Backend/src/controllers/bookingController.js) L735-771 | ✅ |
| Backend: updateBookingStatus API | نفس الملف L385-491 | ✅ |
| Socket: nurse_location_update | نفس الملف L756-759 | ✅ |
| **Patient:** Tracking page | [booking_tracking_page.dart](file:///f:/Housepital-AI/Housepital-AI/housepital/lib/features/customer/booking/presentation/pages/booking_tracking_page.dart) | ⚠️ **Static placeholder** |

> [!WARNING]
> **صفحة التتبع عند المريض** (434 سطر) موجودة بس **استاتيكية**: الخريطة placeholder icon مش خريطة فعلية، والبيانات مكتوبة يدوى (اسم "Nurse Sara" و rating "4.9" ثابتين). مفيش real GPS tracking أو OSRM routing. الـ countdown timer بس simulation. محتاجة ربط بالداتا الحقيقية + Socket listener لتحديث اللوكيشن.

---

### 🟢 مرحلة 9: عرض الـ PIN للمريض

> **Scenario 11:** الممرض يوصل ← المريض يعرض PIN ← الممرض يدخل الـ PIN

> [!IMPORTANT]
> **التحليل الأولى كان غلط هنا** — الـ PIN **بيظهر فعلاً** فى ابلكيشن المريض!

| ايه | فين | الحالة |
|-----|-----|--------|
| **Patient:** عرض PIN ("START CODE") | [booking_tracking_page.dart:L209-273](file:///f:/Housepital-AI/Housepital-AI/housepital/lib/features/customer/booking/presentation/pages/booking_tracking_page.dart#L209) | ✅ **موجود!** |
| يقرأ `widget.booking['visitPin']` ويعرضه | نفس الملف L259 | ✅ |
| بيتخفى لما الـ status يبقى `in-progress` | نفس الملف L209 | ✅ |
| **Nurse:** PIN entry page | [pin_verification_page.dart](file:///f:/Housepital-AI/Housepital-AI/housepital_staff/lib/features/nurse/presentation/pages/pin_verification_page.dart) | ✅ **كامل** |
| **Nurse:** Auto-navigate to PIN after "arrived" | [nurse_tracking_page.dart:L202-209](file:///f:/Housepital-AI/Housepital-AI/housepital_staff/lib/features/nurse/presentation/pages/nurse_tracking_page.dart#L202) | ✅ |
| Backend: verifyPinAndStartVisit | [bookingController.js:L659-726](file:///f:/Housepital-AI/Housepital-AI/Backend/src/controllers/bookingController.js#L659) | ✅ |

> [!NOTE]
> الفلو هنا كامل: المريض شايف الـ PIN → الممرض يوصل ويروح صفحة PIN entry → يدخل الكود → الزيارة تبدأ (status = in-progress). **بس** الـ PIN بيعتمد إن `widget.booking['visitPin']` يكون موجود — لازم نتأكد إن الـ booking data بتيجى ومعاها الـ PIN.

---

### 🔴 مرحلة 10: أثناء الزيارة + إنهاء الزيارة

> **Scenario 11-12:** الممرض يقدم الخدمة ← يكتب Visit Report ← يضغط "Finish Visit"

| ايه | فين | الحالة |
|-----|-----|--------|
| Backend: completeVisit endpoint | [bookingController.js:L773-850](file:///f:/Housepital-AI/Housepital-AI/Backend/src/controllers/bookingController.js#L773) | ✅ |
| Backend: **Commission deduction on complete** (15%) | نفس الملف L819-833 → يستخدم `walletService.deductNurseCommission` | ✅ |
| Booking model: visitReport field | [Booking.js](file:///f:/Housepital-AI/Housepital-AI/Backend/src/models/Booking.js) | ✅ |
| **Nurse App: "In-Progress" state UI** | ❌ | ❌ **بعد الـ PIN يرجع الـ Home** |
| **Nurse App: Visit Report form** | ❌ | ❌ |
| **Nurse App: "Complete Visit" button** | ❌ | ❌ |
| **Patient App: عرض status "In Progress"** | [booking_tracking_page.dart:L142-143](file:///f:/Housepital-AI/Housepital-AI/housepital/lib/features/customer/booking/presentation/pages/booking_tracking_page.dart#L142) | ⚠️ يعرض "Service In Progress" بس بدون تفاصيل |
| **Patient App: عرض الريبورت بعد الزيارة** | ❌ | ❌ |

> [!CAUTION]
> **ده أكبر gap فى الفلو الحالى:** بعد ما الممرض يدخل الـ PIN ويبدأ الزيارة، الابلكيشن بيعمل `Navigator.pop(context)` ويرجع الـ Home. **مفيش**:
> - صفحة "In Progress" عند الممرض
> - زرار "Complete Visit"
> - فورم لكتابة Visit Report
>
> الـ Backend endpoint (`POST /bookings/:id/complete`) **جاهز** بس مفيش UI يستدعيه.

---

### 🟡 مرحلة 11: الفاتورة والتقييم (Patient App)

> **Scenario 12:** الفاتورة + الدفع + التقييم المتبادل

| ايه | فين | الحالة |
|-----|-----|--------|
| **Patient: Invoice page** | [booking_invoice_page.dart](file:///f:/Housepital-AI/Housepital-AI/housepital/lib/features/customer/booking/presentation/pages/booking_invoice_page.dart) | ⚠️ **موجودة بس hardcoded** |
| Invoice line items | نفس الملف L24-29 (servicePrice hardcoded 150, toolsFee 50, discount 10) | ⚠️ مش dynamic |
| Star rating UI (1-5 stars) | نفس الملف L218-240 | ✅ **UI جاهز** |
| Review text field | نفس الملف L245-268 | ✅ **UI جاهز** |
| "Back to Home" button | نفس الملف L290-292 (popUntil first) | ✅ |
| **بس: مفيش API call لحفظ الـ rating** | — | ❌ |
| **بس: مفيش حساب فاتورة حقيقى** | — | ❌ |
| **بس: مفيش ربط بالبيانات الحقيقية** | "Rate Nurse Sara" hardcoded | ❌ |

> [!NOTE]
> الصفحة **موجودة ومصممة** بس:
> 1. الأرقام hardcoded (مش من الـ booking الحقيقى)
> 2. الـ rating مبيتحفظش فى الباكند (مفيش API call)
> 3. الـ nurse name hardcoded "Nurse Sara"
> 4. بتتنادى من زرار "Simulate Visit Completion" فى الـ tracking page

---

### 🟢 ✨ مرحلة 12: Wallet + Commission (Nurse App)

> **Scenario 27:** صفحة أرباح ← رصيد متاح ← سحب

> [!IMPORTANT]
> **التحليل الأولى كان غلط هنا** — الـ Wallet **متنفذة بالكامل**!

| ايه | فين | الحالة |
|-----|-----|--------|
| **Nurse App: Wallet page** | [wallet_page.dart](file:///f:/Housepital-AI/Housepital-AI/housepital_staff/lib/features/nurse/presentation/pages/wallet_page.dart) **(657 سطر)** | ✅ **كامل** |
| Balance card (gradient + blocked state) | نفس الملف L370-429 | ✅ |
| Blocked account banner | نفس الملف L431-455 | ✅ |
| Warning banner (negative balance) | نفس الملف L457-474 | ✅ |
| Recharge button (Card / Mobile Wallet) | نفس الملف L45-210 | ✅ |
| Quick amount buttons (50/100/200/500) | نفس الملف L108-126 | ✅ |
| Transaction history list | نفس الملف L516-605 | ✅ |
| Commission info card | نفس الملف L497-514 | ✅ |
| PayMob WebView integration | نفس الملف L233-247 | ✅ |
| Mobile Wallet redirect | نفس الملف L272-308 | ✅ |
| **Backend: walletService.js** | [walletService.js](file:///f:/Housepital-AI/Housepital-AI/Backend/src/services/walletService.js) **(280 سطر)** | ✅ |
| Atomic balance adjustment (MongoDB $inc) | نفس الملف L59-105 | ✅ |
| Threshold enforcement (-150 EGP) | نفس الملف L113-142 | ✅ |
| Auto-block / unblock | نفس الملف L121-141 | ✅ |
| deductNurseCommission (15%) | نفس الملف L178-204 | ✅ |
| deductDoctorCommission (10%) | نفس الملف L214-229 | ✅ |
| Transaction history | نفس الملف L242-265 | ✅ |
| **Backend: paymobService.js** | [paymobService.js](file:///f:/Housepital-AI/Housepital-AI/Backend/src/services/paymobService.js) **(334 سطر)** | ✅ |
| Auth + Order + Payment Key | نفس الملف | ✅ |
| Card flow (iframe) | نفس الملف L158-160 | ✅ |
| Mobile Wallet flow (redirect) | نفس الملف L175-206 | ✅ |
| HMAC verification | نفس الملف L218-254 | ✅ |
| **Backend: walletController.js** | [walletController.js](file:///f:/Housepital-AI/Housepital-AI/Backend/src/controllers/walletController.js) | ✅ |
| GET /wallet/balance | نفس الملف L22-55 | ✅ |
| GET /wallet/transactions | نفس الملف L62-86 | ✅ |
| POST /wallet/recharge/initiate | نفس الملف L94-216 | ✅ |
| POST /wallet/recharge/callback (HMAC) | نفس الملف L223-297 | ✅ |
| GET /wallet/recharge/status/:orderId | نفس الملف L304-347 | ✅ |
| **Backend: walletRoutes.js** | [walletRoutes.js](file:///f:/Housepital-AI/Housepital-AI/Backend/src/routes/walletRoutes.js) | ✅ |

---

## 🚫 سيناريوهات الإلغاء — الحالة

| السيناريو | Backend | Patient App | Nurse App |
|-----------|:-------:|:-----------:|:---------:|
| **Scenario 13: إلغاء مبكر** (قبل accept) | ✅ cancelMatchingRequest | ✅ | — |
| **Scenario 13: إلغاء booking عادى** | ✅ cancelBooking | ✅ | — |
| **Scenario 14: إلغاء متأخر** (+ رسوم + تعويض) | ❌ | ❌ | ❌ |
| **Scenario 15: إلغاء بواسطة الممرض** (+ re-queue) | ❌ | ❌ | ❌ |
| **Scenario 16A: No-Show** (تايمر 10 دقايق + رسوم) | ❌ | ❌ | ❌ |
| **Scenario 16B: مشكلة أمان/طبية** | ❌ | ❌ | ❌ |

---

## 🗺️ خريطة الملفات الكاملة

### Backend
```
Backend/src/
├── models/
│   ├── MatchingRequest.js     ✅ كامل
│   ├── NurseOffer.js          ✅ كامل
│   ├── Booking.js             ✅ كامل
│   ├── Transaction.js         ✅ كامل
│   ├── Rating.js              ✅ Model فقط (مفيش endpoints)
│   └── Nurse.js               ✅ (+ wallet fields)
├── services/
│   ├── matchingService.js     ✅ كامل (1086 سطر — 4-phase algorithm)
│   ├── pricingService.js      ✅ كامل (Haversine + fees)
│   ├── walletService.js       ✅ كامل (280 سطر — commission + threshold)
│   ├── paymobService.js       ✅ كامل (334 سطر — Card + Mobile Wallet)
│   └── socketManager.js       ✅ كامل
├── controllers/
│   ├── matchingController.js  ✅ كامل
│   ├── bookingController.js   ✅ كامل (PIN verify + complete visit + commission)
│   └── walletController.js    ✅ كامل (balance + recharge + callback)
├── routes/
│   ├── matchingRoutes.js      ✅ كامل + Swagger
│   ├── bookingRoutes.js       ✅ كامل
│   └── walletRoutes.js        ✅ كامل
└── server.js                  ✅ (Socket.io + rooms)
```

### Patient App (housepital)
```
housepital/lib/features/customer/
├── services/
│   └── presentation/pages/
│       ├── services_page.dart               ✅ قائمة الخدمات
│       └── service_details_page.dart        ✅ تفاصيل + Request
├── booking/
│   └── presentation/
│       ├── pages/
│       │   ├── booking_step1_select_patient.dart   ✅ تفاصيل + طلب
│       │   ├── booking_matching_screen.dart         ✅ بحث + عروض
│       │   ├── bookings_page.dart                   ✅ قائمة الحجوزات
│       │   ├── booking_tracking_page.dart           ⚠️ تتبع (PIN ✅ بس map placeholder)
│       │   ├── booking_invoice_page.dart            ⚠️ فاتورة (hardcoded + rating UI بدون API)
│       │   └── clinic_*.dart                        ✅ حجز عيادة
│       └── widgets/
│           ├── booking_card_*.dart                  ✅
│           └── booking_cancellation_modal.dart      ✅
```

### Nurse App (housepital_staff)
```
housepital_staff/lib/features/nurse/
├── presentation/
│   ├── pages/
│   │   ├── nurse_home_page.dart                   ✅ Socket + offers
│   │   ├── nurse_tracking_page.dart               ✅ Real map + OSRM + GPS
│   │   ├── pin_verification_page.dart             ✅ PIN entry
│   │   ├── wallet_page.dart                       ✅ Wallet + PayMob (657 سطر)
│   │   └── nurse_profile_completion_page.dart     ✅
│   ├── cubit/
│   │   ├── nurse_booking_cubit.dart               ✅ state + API
│   │   └── wallet_cubit.dart                      ✅ wallet state management
│   └── widgets/
│       └── nurse_home_widgets.dart                ✅
```

---

## ⚡ ترتيب الأولويات — ايه المفروض يتعمل الأول؟

### 🔴 Priority 1 — الفلو مكسور بدونها

> بعد ما الممرض يدخل الـ PIN ويبدأ الزيارة → الابلكيشن بيرجع Home ومفيش طريقة يخلص بيها الزيارة

1. **Nurse App: صفحة "In Progress"** — شاشة بتظهر بعد الـ PIN فيها:
   - معلومات المريض والخدمة
   - Timer عداد مدة الزيارة
   - فورم Visit Report (text field)
   - زرار **"Complete Visit"** → `POST /bookings/:id/complete` (body: `{ report }`)

---

### 🟡 Priority 2 — تجربة مستخدم أساسية

2. **Patient App: Tracking page ← ربط بالداتا الحقيقية:**
   - اسم الممرض الحقيقى + صورته + rating (من الـ booking data)
   - Socket listener لـ `nurse_location_update` ← تحريك marker على الخريطة (إستبدال placeholder بـ flutter_map)
   - عرض ETA حقيقى (من السيرفر أو OSRM)

3. **Patient App: Invoice page ← ربط بالداتا الحقيقية:**
   - servicePrice + destinationFee + totalAmount من الـ booking
   - اسم الممرض الحقيقى
   - عرض الـ Visit Report

4. **Rating API endpoint + ربطه بالـ UI:**
   - Backend: `POST /bookings/:id/rate` → حفظ فى Rating model + تحديث nurse average
   - Patient App: ربط الـ stars + review بالـ API call
   - Nurse App: عمل صفحة rating للمريض بعد الزيارة

---

### 🟠 Priority 3 — Business Logic

5. **Late cancellation fees** (Scenario 14) — رسوم + تعويض
6. **Nurse emergency cancel** (Scenario 15) — re-queue بـ high priority
7. **No-Show timer** (Scenario 16A) — 10 دقايق + penalty
8. **Equipment deposit flow** (Scenario 8) — UI + payment

---

### ⚪ Priority 4 — Enhancement

9. **Communication channels** (Chat/Call) — فى الـ tracking pages
10. **Prescription upload** — Camera + Cloudinary
11. **Bank withdrawal** — مش موجود (PayMob recharge فقط)
