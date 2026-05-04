# Housepital (Customer App) - Feature Map

This document serves as a detailed map of the features and screens inside the `housepital` application, designed specifically for patients and their dependents.

---

## 1. Onboarding & Initialization
**Path:** `lib/features/splash/` & `lib/features/onboarding/`
*   **Splash Screen:** Initializes app services, checks authentication status.
*   **Onboarding (`onboarding_page.dart`):** Introduction screens explaining the value proposition of the app (e.g., booking nurses, doctors, AI chatbot).

---

## 2. Authentication & Identity Verification
**Path:** `lib/features/auth/presentation/pages/`
*   **Login & Registration:** Standard email/phone sign-in (`login_page.dart`, `register_page.dart`).
*   **OTP & Password Recovery:** Secure authentication flows (`otp_page.dart`, `forgot_password_page.dart`, `reset_password_otp_page.dart`, `new_password_page.dart`).
*   **Identity Verification (eKYC):** 
    *   Scanning National ID (`scan_national_id_page.dart`).
    *   Verification statuses (`verify_identity_page.dart`, `verifying_identity_page.dart`, `verification_success_page.dart`).
*   **Medical Setup:** Initial data collection (`medical_history_page.dart`).

---

## 3. Home & Dashboard
**Path:** `lib/features/customer/home/presentation/pages/`
*   **Customer Home (`customer_home_page.dart`):** The main dashboard displaying upcoming appointments, quick access to services (Nursing, Clinics), and wallet balance.
*   **Health Details (`my_health_details_page.dart`):** High-level view of patient vitals and immediate medical summaries.
*   **Nursing Services (`all_nursing_services_page.dart`):** Quick directory for specifically requesting nursing assistance.

---

## 4. Discovery & Booking Engine
**Path:** `lib/features/customer/booking/presentation/pages/`
*   **Discovery (`clinic_discovery_page.dart`):** Browsing available clinics and facilities.
*   **Booking Flow:**
    *   **Patient Selection (`booking_step1_select_patient.dart`):** Choose if the booking is for the main user or a dependent.
    *   **Clinic Booking (`clinic_booking_page.dart`):** Interface for selecting time slots and services at a specific clinic.
*   **Matching System (`booking_matching_screen.dart`):** UI that shows the algorithm searching for the nearest available doctor/nurse.
*   **Live Tracking (`booking_tracking_page.dart`):** Real-time GPS map interface to track the assigned nurse/doctor as they travel to the patient's location.
*   **History & Invoices:**
    *   **Bookings List (`bookings_page.dart`):** Past and upcoming appointments.
    *   **Invoices (`booking_invoice_page.dart`):** Post-visit financial summaries.

---

## 5. Profile & Account Management
**Path:** `lib/features/customer/profile/presentation/pages/`
*   **Main Profile (`profile_page.dart`):** Navigation hub for user settings.
*   **Family & Dependents:** Managing linked patient profiles (`family_page.dart`, `add_dependent_page.dart`, `edit_dependent_page.dart`).
*   **Addresses:** Managing saved locations for home visits (`saved_addresses_page.dart`, `add_address_page.dart`, `edit_address_page.dart`, `location_picker_page.dart`).
*   **Financials:** Managing balance (`wallet_page.dart`) and subscriptions (`subscription_page.dart`).
*   **Medical Records (`medical_records_page.dart`):** Accessing past visit reports, prescriptions, and lab results.

---

## 6. Services & General Settings
*   **Services (`lib/features/customer/services/presentation/pages/`):** 
    *   Detailed view of offered medical services (`services_page.dart`, `service_details_page.dart`).
*   **Settings (`lib/features/customer/settings/presentation/pages/`):** 
    *   App preferences and personal info (`settings_page.dart`, `personal_info_page.dart`).

---

## 7. AI Chatbot
**Path:** `lib/features/chatbot/presentation/pages/`
*   **Chatbot Interface (`chatbot_page.dart`):** Intelligent virtual assistant capable of symptom checking, answering medical FAQs, and helping patients navigate the app to book appropriate services.

---

## 8. Communications
**Path:** `lib/features/notifications/presentation/pages/`
*   **Notifications (`notifications_page.dart`):** Inbox for system alerts, booking confirmations, matching success updates, and doctor arrival notices.
