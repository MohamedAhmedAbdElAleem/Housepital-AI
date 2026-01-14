# Housepital AI Scenarios

## Introduction
This document outlines the sequence of scenarios and core workflows for the **Housepital AI** application. It covers the complete journey starting from new user registration, managing dependents, requesting services (home nursing and clinic booking), execution, and closure, as well as handling exceptional cases like order cancellations. This document serves as the **"Single Source of Truth"** for the team to align on how users interact with the platform at every stage.

## Definitions of Roles (Actors)
- **Customer**: The "Care Manager" responsible for interactions within the app.
- **Patient**: The person receiving the medical service.
- **Nurse**: The accredited medical service provider for home visits.
- **Doctor**: The accredited medical service provider in the clinic.
- **Admin**: The system employee responsible for administrative and supervisory operations.

---

## Part 1: Onboarding and Patient Management
### Scenario 1: Registering a New Customer
**Goal**: A new customer successfully registers and verifies their account to be ready to use the app.
**Steps**:
1. **Start Registration**: Opens the app and selects "Create New Account".
2. **Enter Data**: Fills in mandatory fields (Name, Email, Mobile Number, Password).
3. **Immediate Verification (Mandatory)**: The app asks the customer to verify their identity immediately. They upload a photo of their ID card, which is verified via an instant verification service.
4. **Onboarding Wizard**: After verification, a welcome screen appears asking about their next step ("Add my medical profile", "Add a family member", "Skip for now").
5. **Skip Logic**: If they choose "Skip", they enter as a "Browser". Upon the first attempt to request a service, they will be forced to add a patient profile first.

### Scenario 2: Customer Adds Themselves as a Patient
**Goal**: The customer fills in their medical profile to be able to request services for themselves.
**Steps**:
1. Selects "Add my medical profile".
2. Enters basic medical data (Date of Birth, Gender, Chronic Diseases, Allergies).
**Result**: Their profile is saved, and the "Add my medical profile" option disappears from menus to prevent duplication.

### Scenario 3: Customer Adds a New "Dependent" (No Account)
**Goal**: The customer adds a family member who does not use the app.
**Steps**:
1. Selects "Add a family member" then "Add new person".
2. Fills in dependent data (Name, Relationship, Medical Data, Address, and optional mobile number for coordination).
3. Uploads dependent's ID proof photo (Mandatory).
**Result**: A profile is created for the dependent and remains "Pending Review" until approved by Admin.

### Scenario 4: Customer Adds a "Dependent" (Has Account)
**Goal**: The customer requests to manage another patient's account who already has an account.
**Steps**:
1. Customer sends an invitation via the patient's email/mobile.
2. Patient receives the invitation and approves it, specifying the level of access granted to the customer.
**Result**: The two accounts are linked according to the specified permissions.

### Scenario 5: Admin Approves a New "Dependent"
**Goal**: Admin reviews and activates the new dependent's profile.
**Steps**:
1. Admin reviews the verification request in the dashboard.
2. Compares data with the ID proof photo.
3. Presses "Approve" or "Reject" with a reason.
**Result**: The customer receives a status notification, and the dependent becomes ready to receive services upon approval.

---

## Part 2: End-to-End Booking Flow
### Scenario 6: Browsing and Selecting Service
**Goal**: The customer finds the desired service easily and starts the booking process.
**Steps**:
1. Customer opens "Services Page".
2. Uses service categories to find the required service.
3. Selects a specific service and presses "Request Service".

### Scenario 7: Patient Selection
**Goal**: The customer identifies the beneficiary of this service.
**Steps**:
1. App displays "Who is this service for?" screen with a list of available patients.
2. "Default Patient" is automatically selected.
3. Customer confirms selection or chooses another patient.

### Scenario 8: Service Options and Equipment Deposit
**Goal**: The customer determines the equipment provision mechanism and pays a deposit to cover its cost upfront.
**Steps**:
1. App asks: "Do you have the equipment or do you want the nurse to bring it?"
2. If they have it: Moves to the next step.
3. If they want the nurse to bring it:
    - App displays an estimated "Equipment Deposit" amount.
    - Customer pays the deposit immediately to complete the request.

### Scenario 9: Scheduling and Additional Details
**Goal**: The customer determines the service time and adds any necessary details.
**Steps**:
1. **Time**: Chooses between "Immediate/Now" or "Scheduled".
2. **Prescription Upload**: Uploads a photo of the medical prescription (Mandatory for certain services).
3. **Nurse Preference**: Specifies preference (Any, Male Nurse, Female Nurse).
4. **Notes**: Writes any notes.
5. Presses "Find Nurse" or "Confirm Booking".

### Scenario 10: Matching and Acceptance Process
**Goal**: The system finds the best available and matching nurse.
**System Steps**:
- **Filtering**: Filters nurses based on (Specialty, Location, Gender, Availability).
- **Ranking**: Ranks nurses based on (Proximity, Rating, Response Speed).
- **Dispatch**: Sends the request in batches to the best nurses.
**Nurse Steps**:
1. Receives a notification with request details.
2. Presses "Accept".
**Result**: Booking is confirmed, and both parties are notified.

### Scenario 11: Active Visit and Communication
**Goal**: Enable the customer to track the visit and enable the nurse to communicate effectively.
**Steps**:
1. **Tracking**: Customer sees nurse details, location on map, and ETA.
2. **Communication Channels**: Nurse has two channels: "In-App Chat/Call" (Official with Customer) and "Direct Call to Patient" (Logistical coordination).
3. **Start Visit (Secure)**: Upon nurse arrival, a PIN code appears in the customer's app. The nurse cannot start the visit without entering this code.
4. **Documentation & Finish**: Nurse provides service, documents it in "Visit Report", then presses "Finish Visit".

### Scenario 12: Final Invoice, Payment, and Rating
**Goal**: Close the visit financially and administratively in a transparent manner.
**Steps**:
1. **Invoice Issuance**: System automatically calculates final invoice: (Actual Service Cost + Actual Equipment Cost - Paid Deposit).
2. **Payment**: Customer receives invoice notification and pays the due amount.
3. **Mutual Rating**: After payment, Customer and Nurse are asked to rate each other.
4. **Close Visit**: Medical report becomes available to the customer, and nurse's earnings are settled.

---

## Part 3: Cancellation Scenarios and Exceptions
### Scenario 13: Early Cancellation by Customer
**Case**: Customer cancels request before any nurse accepts.
**Financial Impact**: No cancellation fees, 100% refund of "Equipment Deposit".

### Scenario 14: Late Cancellation by Customer
**Case**: Customer cancels request after nurse accepts.
**Financial Impact & Nurse Compensation**:
- "Late Cancellation Fee" deducted from customer as compensation to nurse.
- Customer loses "Equipment Deposit".
- For nurse to get equipment compensation, they must upload mandatory proof: Purchase invoice photo + Photo of equipment out of sterile packaging.
- Admin reviews request and approves compensation.

### Scenario 15: Cancellation by Nurse (Personal/Emergency)
**Case**: Nurse cancels request after accepting due to emergency.
**Action**:
1. Nurse cancels visit stating the reason.
2. Customer receives apology notification.
3. System automatically reposts request in matching queue with "High Priority".
**Impact on Nurse**: Cancellation negatively affects their "Visit Completion Rate".

### Scenario 16: Cancellation Upon Arrival (Hybrid: Automated/Manual)
**Case**: Nurse arrives at customer location but cannot start visit.
**Action**: Nurse presses "Report Issue" and selects reason.

#### Scenario 16A: Automated - "Customer No-Show"
**Goal**: Enable nurse to cancel visit automatically after proving attempt to connect.
**Steps**:
1. Nurse selects "Customer No-Show".
2. System starts "Wait Timer" for 10 minutes and sends urgent notification to customer.
3. System requires nurse to prove communication attempt (via Chat/Internal Calls).
4. After timer ends, if no response, "Cancel Visit (No-Show)" button activates.
**Financial Impact**: Request cancelled automatically, "No-Show" fee deducted from customer and transferred as compensation to nurse.

#### Scenario 16B: Manual - (Safety Issues or Medical Mismatch)
**Goal**: Route complex cases needing human decision to Admin.
**Steps**:
1. Nurse selects "Service not as described" or "I feel unsafe".
2. System transfers them to priority support channel to talk to Admin.
**Financial Impact**: Decided by Admin based on case, usually if fault is customer's, fee is deducted and transferred to nurse.

---

## Part 4: Doctor Journey and Clinic Booking
### Scenario 17: New Doctor Registration and Clinic Verification
**Goal**: New doctor registers, adds professional details and clinic data, and gets verified.
**Steps**:
1. Create Basic Account.
2. Fill Professional Profile (Specialty, Experience, License).
3. Add Clinic Details (Address, Photos, Proof Documents).
4. Submit complete profile for Admin review and approval.

### Scenario 18: Doctor Defines Service Menu (Multi-Clinic Support)
**Goal**: Enable doctor to create a single service and apply it to multiple clinics in one step.
**Steps**:
1. Presses "Add New Service".
2. Enters service details (Name, Price, Duration).
3. Checklist of all verified clinics appears.
4. Selects clinics to apply this service to and saves.

### Scenario 19: Doctor Manages Schedule and Advanced Booking Settings
**Goal**: Doctor chooses clinic management method and sets advanced booking policies.
**Steps**:
1. **Booking Method**: Chooses between "Slots" or "Queue".
2. **Schedule**: Sets working days and hours based on chosen system.
3. **Advanced Settings**:
    - "Min Advance Booking" (e.g., 3 hours).
    - "Urgent Bookings" toggle with surcharge percentage (e.g., +25%).

### Scenario 20: Patient Journey to Book Clinic Appointment
**Goal**: Patient searches for doctor and confirms booking successfully, utilizing advanced options.
**Steps**:
1. **Search**: Patient searches by Specialty, Name, or Location. System hides appointments within "Min Advance Booking" window unless "[ ] Show Urgent" filter is active.
2. **Results**: Doctor cards appear. If "Urgent" filter is on, near appointments show with new price/badge.
3. **Page**: Patient selects Doctor, Clinic, Service.
4. **Slots**: Shows appropriate booking interface (Calendar or Queue).
5. **Prepayment**: Patient pays full fee to confirm.
6. **Confirmation**: Notification sent to both.

### Scenario 21: Clinic Cancellation Policies
**Goal**: Define clear logic for cancellations.
**Policies**:
- **Patient Cancellation**:
    - Early (>24h): 100% Refund.
    - Late (<24h): 75% Refund.
    - Very Late (<3h): 50% Refund.
    - No-Show: 0% Refund.
- **Doctor Cancellation**:
    - Patient gets 100% Refund + Extra credit/goodwill.
    - Negatively impacts Doctor's "Reliability Rate".

### Scenario 22: Patient Arrival and Authentication (Dual QR + PIN)
**Goal**: Digital verification of attendance.
**Doctor View**: Shows QR Code + 4-digit PIN.
**Patient View**: Arrives, presses "Check-in", scans QR OR enters PIN.
**Result**: Booking status changes to Checked-in.

---

## Part 5: The Nurse's Journey
### Scenario 23: New Nurse Registration and Profile Verification
**Goal**: Nurse registers and provides documents for Admin review.
**Steps**:
1. Create Basic Account.
2. **Upload Docs**: ID, Degree, License.
3. **Profile**: Skills (Wound care, Cannula, etc.), Experience Years, Bio.
4. **Bank Info**: For earnings.
5. **Submit**: Profile becomes "Under Review".

### Scenario 24: Admin Reviews and Verifies Nurse Account
**Goal**: Admin verifies data.
**Steps**:
1. Admin opens "Verification Queue".
2. Reviews docs.
3. (Optional) Video call interview.
4. Result: Approve (Nurse can work) or Reject (Reason given).

### Scenario 25: Nurse Manages Availability and Work Zone
**Goal**: Nurse controls when/where to work.
**Steps**:
1. **Availability**: Toggle "Online/Offline".
2. **Work Zone**: Set Center Point + Radius (e.g., 10 km).

### Scenario 26: Nurse Receives and Reviews Request
**Goal**: Quick decision making.
**Steps**:
1. System sends urgent notification.
2. **Request Card**: Service type, Distance/Time, Expected Earnings, Equipment info, Patient Rating.
3. **Timer**: 60 seconds to Accept/Reject.

### Scenario 27: Nurse Manages Wallet and Earnings
**Goal**: Financial transparency.
**Steps**:
1. "My Earnings" page.
2. **Details**: Withdrawable Balance, Pending Balance, Transaction History.
3. **Withdraw**: Enter amount -> Transfer to Bank/Wallet (2-3 days).

---

## Part 7: AI Chatbot Journey
### Scenario 28: First Interaction and Safety Boundaries
**Steps**:
1. User opens Chatbot.
2. Mandatory Welcome Message enforcing safety limits (Not a doctor replacement, Call 123 for emergencies).
3. User must "Agree" to proceed.

### Scenario 37: Context-Aware Smart Chat
**Steps**:
1. User clicks Chatbot.
2. Screen asks: "Who are we talking about?" (Patient Selection).
3. User selects patient (e.g., Mother).
4. Chat opens with context "Talking about: Mother". System feeds her medical profile to AI.

### Scenario 29: Symptom Triage
- **Low Risk**: Advice + Suggest Nursing Service.
- **Medium Risk**: Suggest Doctor Booking.
- **High Risk**: STOP -> Show Emergency Warning + Call Button.

### Scenario 30: Health Education
**Goal**: General info (e.g., Anemia symptoms). AI clarifies it's general info, implies booking doctor.

### Scenario 31: Care Management Tool
**Goal**: AI performs app actions.
**Example**: "Remind me to take diabetes med at 8 AM". AI confirms -> Sets app reminder.

---

## Part 8: Plans & Subscriptions Journey
### Scenario 32: Admin Creates Flexible Plans
**Goal**: Admin creates Subscriptions (Recurring) or Packages (One-off).

### Scenario 33: Customer Subscribes
**Goal**: Customer browses "Plans & Offers", selects, and pays.

### Scenario 34: Subscriber Books Service
**Goal**: Auto-apply benefits (discounts/free visits) at checkout.

### Scenario 36: Premium Experience
**Goal**: App transforms for subscribers. Home page becomes "My Health Dashboard" with dynamic cards (Tips, Adherence tracking).

### Scenario 35: Subscription Management
**Goal**: Customer can Upgrade/Downgrade/Cancel from profile.

---

## Part 9: Admin Dashboard & Team
### Roles:
- **Owner**: God Mode.
- **Ops Manager**: Live Map, Dispatch, Strategy.
- **Quality Specialist**: Vetting, Performance Review.
- **Support**: Complaints, Refunds.
- **Finance**: Payouts, Reports.

### Scenarios 38-44:
Cover specific workflows for each admin role (Vetting, Monitoring Performance, Managing Live Ops, Handling Disputes, Finances, etc.).
