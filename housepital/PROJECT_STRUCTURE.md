# 🏥 Housepital - AI-Powered Home Healthcare Platform

## 📋 Project Structure

```
lib/
├── config/                 # App configuration
│   ├── routes/            # Navigation & routing
│   └── theme/             # App theme & styling
├── core/                  # Core functionality
│   ├── constants/         # App constants (colors, strings, routes, API)
│   ├── enums/            # Enumerations (user types, service types)
│   ├── errors/           # Error handling & failures
│   ├── network/          # API client
│   └── utils/            # Utilities (validators, etc.)
├── features/             # Feature modules
│   ├── splash/           # Splash screen
│   ├── onboarding/       # 2 Intro pages
│   ├── auth/             # Login, Register, OTP, Email Verification
│   ├── customer/         # Customer features
│   │   ├── home/         # Home page
│   │   ├── services/     # Services catalog & booking
│   │   └── profile/      # Profile & settings
│   ├── nurse/            # Nurse features
│   │   ├── home/         # Nurse dashboard
│   │   └── requests/     # Service requests
│   ├── doctor/           # Doctor features
│   │   └── home/         # Doctor dashboard
│   └── chatbot/          # AI Chatbot
└── shared/               # Shared resources
    ├── models/           # Common models
    └── widgets/          # Reusable widgets
```

## 👥 User Types

- **Customer** (Patient or Patient's family)
- **Nurse** (Assigned by Ministry of Health with nursing card)
- **Doctor** (Supervising doctor)
- **Admin** (Stakeholders, Accountants, Customer Services)

## 🏥 Services

### Service Types
- **Scheduled** - Pre-booked appointments
- **Urgent** - Emergency services
- **Regular** - Standard services

### Service Categories

1. **Post-Surgical Care**
   - Wound Care and Dressing
   - Catheter/Cannula Insertion & Replacement
   - Suture/Staple Removal

2. **Elderly / Chronic Diseases Care**
   - Bedsores treatment
   - Long-term care

3. **Injection Services**
   - Intramuscular injections

4. **Broken Bones**
   - Bracing and support

## 🔄 User Flow

### Customer Flow
1. Choose a service from available options
2. AI assistant provides status and recommendations
3. Submit service request with preferences
4. Wait for nurse/doctor acceptance
5. Chat with assigned provider
6. Service completion & rating

### Nurse/Doctor Flow
1. View new service requests
2. Accept or decline requests
3. View patient information
4. Chat with patient
5. Complete service
6. Upload service report
7. Get rated by customer

## 🤖 AI Features

- Automated medicine reminders
- Computer vision for low-risk wound monitoring
- Text classification for triage (BERT NLP)
- Personalized lifestyle recommendations
- Demand forecasting
- Dynamic incentivization

## 📦 Main Dependencies

- **State Management**: Provider, Flutter Bloc
- **Network**: Dio, HTTP
- **Local Storage**: Shared Preferences, Hive
- **Navigation**: Go Router
- **Chat**: Socket.io
- **Maps**: Google Maps, Geolocator
- **UI**: Lottie, Shimmer, Pinput (OTP)

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.7.2+)
- Android Studio / VS Code
- Android Emulator or Physical Device

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Housepital-AI/housepital
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Features To Implement

### Phase 1 (Current - Structure Setup) ✅
- [x] Project structure
- [x] Core constants and utilities
- [x] Basic navigation setup
- [x] Page placeholders

### Phase 2 (Authentication)
- [ ] Splash screen with animation
- [ ] Onboarding pages (2 pages)
- [ ] Login page with validation
- [ ] Register page with user type selection
- [ ] Email verification
- [ ] OTP verification
- [ ] Forgot password flow

### Phase 3 (Customer Features)
- [ ] Customer home page with services
- [ ] Service catalog with filtering
- [ ] Service booking flow
- [ ] AI Chatbot integration
- [ ] Profile management
- [ ] Medical history
- [ ] Booking history
- [ ] Rating system

### Phase 4 (Provider Features)
- [ ] Nurse/Doctor dashboard
- [ ] New requests page
- [ ] Accept/Decline requests
- [ ] Current services management
- [ ] Chat with patients
- [ ] Service report upload
- [ ] Statistics & wallet

### Phase 5 (Backend Integration)
- [ ] API integration
- [ ] WebSocket for real-time chat
- [ ] Push notifications
- [ ] Image upload
- [ ] Location services

### Phase 6 (AI Features)
- [ ] Chatbot integration
- [ ] Triage system
- [ ] Recommendations engine
- [ ] Wound monitoring

## 📝 Notes

- All pages are created as placeholders with TODO comments
- Backend API endpoints are defined in `core/constants/api_constants.dart`
- Update `baseUrl` in API constants when backend is ready
- Add custom fonts in `assets/fonts/` and update `pubspec.yaml`
- Add images and animations in respective asset folders

## 🔧 Configuration

- **Backend URL**: Update in `lib/core/constants/api_constants.dart`
- **Theme Colors**: Customize in `lib/core/constants/app_colors.dart`
- **App Strings**: Edit in `lib/core/constants/app_strings.dart`

---

**Ready to start development!** 🚀
