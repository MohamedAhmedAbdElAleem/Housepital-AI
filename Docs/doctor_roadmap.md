# Doctor Feature Roadmap

Based on "Housepital AI Scenarios - Part 4: Doctor Journey & Clinic Booking" (Scenarios 17-22).

## Phase 1: Registration & Clinic Management (The Foundation)
**Goal:** Allow a doctor to sign up, verify their identity, and set up their clinics and services.


- [ ] **Scenario 17: Doctor Registration & Verification**
    - [x] **Backend API**:
        - [x] Create `doctorController.js` (createProfile, getProfile, updateProfile).
        - [x] Create `doctorRoutes.js`.
        - [x] Implement Document Upload API (Cloudinary).
    - [x] **Flutter App**:
        - [x] **Basic Info**: Name, Email, Phone, Password (already implemented in generic Auth).
        - [x] **Professional Profile** (Next Step):
            - [x] Specialty (Dropdown).
            - [x] Experience (Years).
            - [x] License Details (Image Upload).
            - [x] Bio.
    - [x] **Clinic Setup**:
        - [x] **Backend API**:
            - [x] Create `clinicController.js` (addClinic, getClinics, updateClinic, deleteClinic).
            - [x] Create `clinicRoutes.js`.
        - [x] **Flutter App**:
            - [x] Add Clinic Name & Address.
            - [x] Upload Clinic Photos (Advanced UI with Carousel).
            - [x] Upload Proof of Ownership/Rent.
            - [x] *Support for multiple clinics* (List View).
            - [x] Edit & Delete Clinic.
    - [ ] **Verification State**: 
        - [ ] Backend: Add verification logic/admin endpoints.
        - [x] UI for "Pending Approval" state (Badges implemented).
        - [ ] Block access to main features until approved by Admin.


- [ ] **Scenario 18: Service Management**  <-- **(NEXT PRIORITY)**
    - [ ] **Backend API**:
        - [ ] Create `serviceController.js` (addService, getServices, updateService).
        - [ ] Create `serviceRoutes.js`.
    - [ ] **Flutter App**:
        - [ ] **Create Service**:
            - [ ] Service Name (e.g., "Consultation", "Follow-up").
            - [ ] Price (EGP).
            - [ ] Duration (Minutes).
        - [ ] **Multi-Clinic Assignment**:
            - [ ] Checklist to apply this service to Clinic A, Clinic B, etc.

## Phase 2: Scheduling & Availability (The Engine)
**Goal:** Give doctors control over their time using flexible booking systems.

- [ ] **Scenario 19: Schedule Configuration**
    - [x] **Booking Mode Selection** (Implemented in Clinic Form):
        - [x] Option A: **Time Slots** (Specific times, e.g., 5:00 PM, 5:30 PM).
        - [x] Option B: **Queue System** (First come first served window).
    - [x] **Working Hours**:
        - [x] Define days of week and hours per clinic.
    - [ ] **Advanced Settings**:
        - [ ] **Min Advance Booking**: (e.g., "No bookings less than 3 hours before").
        - [ ] **Urgent Booking**: Toggle to allow last-minute bookings at a premium price (+%).

## Phase 3: Appointment Operations (The Core Loop)
**Goal:** Manage the lifecycle of a patient visit from booking to completion.

- [ ] **Scenario 20: Appointment Dashboard**
    - [ ] **Upcoming Appointments List**:
        - [ ] Filter by Date / Clinic.
        - [ ] Indicators for "Urgent" bookings.
    - [ ] **Appointment Details**:
        - [ ] Patient Info.
        - [ ] Service Type.
        - [ ] Payment Status (Paid).

- [ ] **Scenario 22: Patient Arrival (Check-in)**
    - [ ] **QR Code Scanner**: Built-in scanner to scan Patient's app.
    - [ ] **PIN Entry**: Fallback manual entry of 4-digit PIN.
    - [ ] **Status Update**: Mark appointment as "Checked-in" instantly.

- [ ] **Scenario 21: Cancellations & Policies**
    - [ ] **Doctor Cancellation**:
        - [ ] Button to cancel appointment.
        - [ ] Reason selection.
        - [ ] Warning about "Reliability Rate" impact.

## Phase 4: Financials & Insights (The Reward)
**Goal:** Transparency in earnings and performance.

- [ ] **Earnings Dashboard** (Adapted from Scenario 27 - Nurse, applied to Doctor):
    - [ ] Total Earnings.
    - [ ] Withdrawable Balance.
    - [ ] Transaction History.
- [ ] **Performance Stats**:
    - [ ] Total Visits.
    - [ ] Patient Ratings.
    - [ ] Reliability Score (Cancellation rate).


---

## Technical Dependencies
- **Backend (New)**:
    - [x] `doctorRoutes` & `doctorController`.
    - [x] `clinicRoutes` & `clinicController`.
    - [ ] `serviceRoutes` & `serviceController`.
    - [ ] `bookingRoutes` (Update for Doctor logic).
- **Backend (Existing)**:
    - [x] `Doctor`, `Clinic`, `Service` models (Already exist).
- **Flutter**:
    - [x] `image_picker` for documents.
    - [ ] `google_maps_flutter` for clinic location.
    - [ ] `qr_code_scanner` or `mobile_scanner` for Check-in.
