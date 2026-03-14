# Housepital — Nurse-Patient Matching Algorithm Documentation

> **Version:** 1.0.0  
> **Last Updated:** 2026-03-14  
> **Backend:** Node.js + Express + MongoDB + Socket.io

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Architecture](#2-architecture)
3. [Matching Algorithm](#3-matching-algorithm)
4. [Pricing Model](#4-pricing-model)
5. [API Reference](#5-api-reference)
6. [Socket.io Events](#6-socketio-events-reference)
7. [Data Models](#7-data-models)
8. [Flow Diagrams](#8-flow-diagrams)
9. [Configuration](#9-configuration)
10. [Testing](#10-testing)

---

## 1. System Overview

The Housepital matching system connects **patients** requesting home nursing services with **nearby available nurses** — similar to ride-hailing apps like InDriver or Careem, but for healthcare.

### Key Features

| Feature | Description |
|---|---|
| **Smart Matching** | Multi-factor scoring algorithm finds the best nurses |
| **Real-time Updates** | Socket.io for instant offer notifications |
| **Distance Pricing** | Egyptian-market destination fees (EGP/km) |
| **10% Commission** | Platform takes 10% from total price |
| **Up to 5 Offers** | Patient sees up to 5 nurse offers at once |
| **60s Nurse Window** | Nurses have 60 seconds to respond to each offer |

### User Roles in Matching

- **Patient (customer):** Creates service requests, sees nurse offers, accepts/declines
- **Nurse:** Receives patient offers, accepts/declines, gets assigned to bookings
- **Admin:** Takes 10% commission from every completed match

---

## 2. Architecture

### Files Created/Modified

```
Backend/src/
├── models/
│   ├── MatchingRequest.js  ← [NEW] Patient request lifecycle
│   ├── NurseOffer.js       ← [NEW] Individual nurse-patient offers
│   └── Booking.js          ← [MODIFIED] Added matching fields
├── services/
│   ├── matchingService.js  ← [NEW] Core matching algorithm
│   └── pricingService.js   ← [NEW] Distance pricing & commission
├── controllers/
│   └── matchingController.js ← [NEW] REST API handlers
├── routes/
│   └── matchingRoutes.js   ← [NEW] Route definitions + Swagger
└── server.js               ← [MODIFIED] Socket.io + matching routes
```

### Technology Stack

| Component | Technology | Purpose |
|---|---|---|
| API | Express.js | REST endpoints |
| Database | MongoDB + Mongoose | Data persistence + geospatial queries |
| Real-time | Socket.io | Push notifications to nurses/patients |
| Auth | JWT (jsonwebtoken) | Authenticate API and Socket.io connections |
| Geospatial | MongoDB 2dsphere indexes | Find nurses by location |
| Distance | Haversine formula | Calculate nurse-to-patient distance |

---

## 3. Matching Algorithm

### Algorithm: Weighted Multi-Factor Scoring with Geospatial Filtering

The algorithm runs in **4 phases** when a patient requests a service:

### Phase 1 — Geospatial Filtering

Uses MongoDB's `$geoNear` aggregation to find nurses within a configurable radius (default: **15 km**).

**Filters applied:**
- ✅ Nurse is **online** (`isOnline: true`)
- ✅ Nurse is **verified** (`verificationStatus: "approved"`)
- ✅ Nurse's User account is **approved** (`user.status: "approved"`)
- ✅ Nurse's **gender** matches patient preference (if specified)
- ✅ Nurse has **skills** matching the service category (or is a generalist)

```javascript
// MongoDB $geoNear query
{
    $geoNear: {
        near: { type: "Point", coordinates: [patientLon, patientLat] },
        distanceField: "calculatedDistanceMeters",
        maxDistance: radiusKm * 1000,  // Convert to meters
        spherical: true,
        query: { isOnline: true, verificationStatus: "approved" }
    }
}
```

### Phase 2 — Weighted Scoring

Each candidate nurse receives a composite score (0.0 to 1.0) based on 5 factors:

| Factor | Weight | Formula | Why |
|---|---|---|---|
| **Distance** | 35% | `1 - (distance / maxRadius)` | Closer nurses arrive faster |
| **Rating** | 25% | `rating / 5` | Better-rated nurses provide better service |
| **Experience** | 15% | `min(yearsOfExperience / 10, 1)` | More experienced = more reliable |
| **Completion Rate** | 15% | `completionRate / 100` | Fewer cancellations = more dependable |
| **Response Time** | 10% | `1 - min(avgResponseTime / 600, 1)` | Faster responders keep things moving |

**Composite Score** = Σ (factor × weight)

**Example Calculation:**

```
Nurse "Sarah" — 3km away, 4.5 rating, 6yr exp, 95% completion, 45s avg response

Distance:    1 - (3/15)      = 0.80  × 0.35 = 0.280
Rating:      4.5/5           = 0.90  × 0.25 = 0.225
Experience:  min(6/10, 1)    = 0.60  × 0.15 = 0.090
Completion:  95/100          = 0.95  × 0.15 = 0.143
Response:    1 - min(45/600) = 0.925 × 0.10 = 0.093
─────────────────────────────────────────────────────
TOTAL SCORE:                                  0.831
```

### Phase 3 — Sort & Limit

- Sort all scored nurses **descending by composite score**
- Return the **top 5** nurses (configurable)

### Phase 4 — Create Offers

For each matched nurse:
1. Calculate **individual pricing** (distance-based) using Haversine formula
2. Create a `NurseOffer` document with full pricing breakdown
3. **Snapshot** the nurse's current info (name, picture, rating, etc.) so it's preserved
4. Send a **Socket.io notification** to the nurse's room
5. Start a **60-second timer** for the nurse to respond

### Why This Algorithm?

| Design Choice | Reasoning |
|---|---|
| **Geospatial pre-filter** | Eliminates distant nurses early, reducing computation |
| **Weighted scoring** | Balances multiple factors rather than just "closest nurse" |
| **Distance as highest weight (35%)** | Patient experience is best when nurse arrives quickly |
| **Rating second (25%)** | Quality of care matters significantly |
| **Denormalized nurse snapshot** | Prevents N+1 queries when patient views offers |
| **60-second window** | Quick enough for ASAP requests, prevents indefinite waiting |

---

## 4. Pricing Model

### Egyptian Market Rates

| Component | Value | Notes |
|---|---|---|
| **Service Price** | Fixed per service | Defined in the Service model, set by admin |
| **Destination Rate** | **3.50 EGP/km** | Based on Egyptian ride-hailing market rates |
| **Min Destination Fee** | **15 EGP** | Floor for very short trips |
| **Max Destination Fee** | **200 EGP** | Cap for very long distances |
| **Platform Commission** | **10%** | Applied to (servicePrice + destinationFee) |
| **Currency** | EGP | Egyptian Pound |

### Pricing Formula

```
destinationFee   = clamp(distanceKm × 3.50, min=15, max=200)
totalPrice       = servicePrice + destinationFee
platformFee      = totalPrice × 0.10
nurseEarnings    = totalPrice - platformFee
```

### Pricing Examples

| Service Price | Distance | Dest. Fee | Total | Platform (10%) | Nurse Gets |
|---|---|---|---|---|---|
| 150 EGP | 2 km | 15 EGP (min) | 165 EGP | 16.50 EGP | 148.50 EGP |
| 150 EGP | 5 km | 17.50 EGP | 167.50 EGP | 16.75 EGP | 150.75 EGP |
| 200 EGP | 10 km | 35 EGP | 235 EGP | 23.50 EGP | 211.50 EGP |
| 300 EGP | 20 km | 70 EGP | 370 EGP | 37 EGP | 333 EGP |
| 300 EGP | 60 km | 200 EGP (max) | 500 EGP | 50 EGP | 450 EGP |

### Distance Calculation — Haversine Formula

The Haversine formula calculates great-circle distance between two GPS coordinates:

```
a = sin²(Δlat/2) + cos(lat₁) × cos(lat₂) × sin²(Δlon/2)
c = 2 × atan2(√a, √(1-a))
distance = R × c       (R = 6371 km)
```

### ETA Estimation

```
ETA = max(distance / 25 km/h × 60, 5 minutes)
```

Average speed of **25 km/h** accounts for Egyptian urban traffic (conservative estimate).

---

## 5. API Reference

All endpoints require JWT Bearer token in the `Authorization` header.

### Patient (Customer) Endpoints

#### POST `/api/matching/request` — Create Matching Request

Triggers the matching algorithm to find nurses.

**Request Body:**
```json
{
    "serviceId": "60d5ec49f1b2c72b9c8e4f1a",
    "latitude": 30.0444,
    "longitude": 31.2357,
    "address": {
        "street": "15 Tahrir Square",
        "area": "Downtown",
        "city": "Cairo",
        "state": "Cairo"
    },
    "nurseGenderPreference": "female",
    "timeOption": "asap",
    "notes": "Patient is elderly, needs gentle care"
}
```

**Response (201):**
```json
{
    "success": true,
    "message": "5 nurse(s) found and notified",
    "matchingRequest": {
        "id": "60d5ec49f1b2c72b9c8e4f1b",
        "status": "offers_pending",
        "serviceName": "Wound Care",
        "servicePrice": 150,
        "matchedCount": 5,
        "expiresAt": "2026-03-14T02:45:00.000Z"
    }
}
```

---

#### GET `/api/matching/my-requests` — Get My Active Requests

Returns all active (non-completed) matching requests.

**Response (200):**
```json
{
    "success": true,
    "count": 1,
    "requests": [
        {
            "id": "60d5ec49f1b2c72b9c8e4f1b",
            "serviceName": "Wound Care",
            "servicePrice": 150,
            "status": "nurse_accepted",
            "location": { "city": "Cairo" },
            "expiresAt": "2026-03-14T02:45:00.000Z"
        }
    ]
}
```

---

#### GET `/api/matching/request/:id` — Get Request Status

Returns detailed status with offer statistics.

**Response (200):**
```json
{
    "success": true,
    "matchingRequest": {
        "id": "...",
        "status": "nurse_accepted",
        "serviceName": "Wound Care",
        "servicePrice": 150,
        "offerStats": {
            "total": 5,
            "nurseAccepted": 3,
            "nursePending": 1,
            "nurseDeclined": 1
        }
    }
}
```

---

#### PUT `/api/matching/request/:id/cancel` — Cancel Request

Cancels the matching request and all pending offers.

**Response (200):**
```json
{
    "success": true,
    "message": "Matching request cancelled"
}
```

---

#### GET `/api/matching/patient-offers/:requestId` — Get Nurse Offers (Patient View)

Patient sees nurse offers (only nurses who accepted). **Up to 5 offers max.**

**Response (200):**
```json
{
    "success": true,
    "count": 3,
    "offers": [
        {
            "offerId": "60d5ec49f1b2c72b9c8e4f1c",
            "nurse": {
                "name": "Sarah Ahmed",
                "profilePictureUrl": "https://res.cloudinary.com/...",
                "rating": 4.5,
                "totalRatings": 47,
                "yearsOfExperience": 6,
                "completedVisits": 120,
                "specialization": "Wound Care",
                "gender": "female"
            },
            "pricing": {
                "servicePrice": 150,
                "destinationFee": 35,
                "totalPrice": 185,
                "currency": "EGP"
            },
            "distanceKm": 4.2,
            "estimatedArrivalMinutes": 11,
            "patientStatus": "pending",
            "matchScore": 0.831
        }
    ]
}
```

---

#### PUT `/api/matching/patient-offers/:offerId/respond` — Accept/Decline Nurse

**Request Body:**
```json
{
    "response": "accepted"
}
```

**Response (200) — When Accepted:**
```json
{
    "success": true,
    "message": "Nurse accepted! Booking created.",
    "offer": {
        "id": "60d5ec49f1b2c72b9c8e4f1c",
        "patientStatus": "accepted"
    },
    "booking": {
        "id": "60d5ec49f1b2c72b9c8e4f1d",
        "status": "confirmed",
        "assignedNurse": "60d5ec49f1b2c72b9c8e4f1e",
        "totalAmount": 185,
        "visitPin": "4729"
    }
}
```

---

#### POST `/api/matching/price-estimate` — Get Price Estimate

Get an estimated price range before requesting.

**Request Body:**
```json
{
    "serviceId": "60d5ec49f1b2c72b9c8e4f1a",
    "estimatedDistanceKm": 5
}
```

**Response (200):**
```json
{
    "success": true,
    "serviceName": "Wound Care",
    "serviceCategory": "wound_care",
    "estimate": {
        "servicePrice": 150,
        "estimatedDestinationFee": 17.50,
        "estimatedTotal": 167.50,
        "priceRange": {
            "min": 158.75,
            "max": 176.25
        },
        "platformFee": 16.75,
        "estimatedArrivalMinutes": 12,
        "currency": "EGP",
        "note": "Final price depends on the nurse's actual distance from your location."
    }
}
```

---

### Nurse Endpoints

#### GET `/api/matching/nurse-offers` — Get Pending Offers (Nurse View)

**Response (200):**
```json
{
    "success": true,
    "count": 2,
    "offers": [
        {
            "offerId": "60d5ec49f1b2c72b9c8e4f1c",
            "patient": {
                "name": "Mohamed Ali",
                "profilePictureUrl": "https://...",
                "rating": 4.2,
                "totalRatings": 8
            },
            "service": {
                "name": "Wound Care",
                "category": "wound_care"
            },
            "location": {
                "street": "15 Tahrir Square",
                "area": "Downtown",
                "city": "Cairo"
            },
            "pricing": {
                "totalPrice": 185,
                "nurseEarnings": 166.50,
                "destinationFee": 35,
                "servicePrice": 150,
                "currency": "EGP"
            },
            "distanceKm": 4.2,
            "estimatedArrivalMinutes": 11,
            "expiresAt": "2026-03-14T02:36:00.000Z"
        }
    ]
}
```

---

#### PUT `/api/matching/nurse-offers/:offerId/respond` — Accept/Decline Offer

**Request Body:**
```json
{
    "response": "accepted"
}
```

**Response (200):**
```json
{
    "success": true,
    "message": "Offer accepted",
    "offer": {
        "id": "60d5ec49f1b2c72b9c8e4f1c",
        "nurseStatus": "accepted",
        "nurseRespondedAt": "2026-03-14T02:35:30.000Z"
    }
}
```

---

## 6. Socket.io Events Reference

### Connection

Connect with JWT token:
```javascript
const socket = io("http://localhost:3500", {
    auth: { token: "your_jwt_token" }
});
```

### Client → Server Events

| Event | Payload | Description |
|---|---|---|
| `nurse:update_location` | `{ latitude, longitude }` | Update nurse's GPS location |
| `nurse:set_online` | `boolean` | Toggle nurse online/offline status |

### Server → Client Events (Nurse)

| Event | Payload | When |
|---|---|---|
| `matching:new_offer` | `{ offerId, patientName, serviceName, distanceKm, totalPrice, nurseEarnings, estimatedArrivalMinutes, expiresAt }` | New patient request matched to this nurse |
| `matching:booking_confirmed` | `{ bookingId, patientName, address, visitPin, totalPrice, nurseEarnings }` | Patient accepted this nurse's offer |
| `matching:offer_cancelled` | `{ offerId, reason }` | Patient selected another nurse or cancelled |

### Server → Client Events (Patient)

| Event | Payload | When |
|---|---|---|
| `matching:no_nurses_found` | `{ matchingRequestId, message }` | No nurses available in area |
| `matching:nurse_offer_available` | `{ matchingRequestId, offerId, nurseSnapshot, totalPrice, destinationFee, estimatedArrivalMinutes }` | A nurse accepted — new offer visible |
| `matching:booking_confirmed` | `{ bookingId, nurseSnapshot, totalPrice, estimatedArrivalMinutes, visitPin }` | Booking created successfully |

---

## 7. Data Models

### MatchingRequest

Lifecycle of a patient's service request.

| Field | Type | Description |
|---|---|---|
| `patientId` | ObjectId→User | Who is requesting |
| `serviceId` | ObjectId→Service | What service |
| `serviceName` | String | Service name (denormalized) |
| `serviceCategory` | String | Category for skill matching |
| `servicePrice` | Number | Fixed service price (EGP) |
| `location` | GeoJSON Point | Patient GPS coordinates |
| `address` | Object | Street, area, city, state |
| `nurseGenderPreference` | Enum | male/female/any |
| `status` | Enum | searching → offers_pending → nurse_accepted → accepted |
| `matchedNurses` | Array | Nurses found with scores |
| `expiresAt` | Date | Auto-expire after 10 minutes |

### NurseOffer

Individual offer between a nurse and a patient.

| Field | Type | Description |
|---|---|---|
| `matchingRequestId` | ObjectId→MatchingRequest | Parent request |
| `nurseId` | ObjectId→Nurse | Which nurse |
| `patientId` | ObjectId→User | Which patient |
| `nurseSnapshot` | Object | Denormalized nurse info (name, photo, rating, experience, etc.) |
| `servicePrice` | Number | Fixed service price |
| `distanceKm` | Number | Haversine distance |
| `destinationFee` | Number | Distance-based fee |
| `totalPrice` | Number | servicePrice + destinationFee |
| `platformFee` | Number | 10% of totalPrice |
| `nurseEarnings` | Number | totalPrice − platformFee |
| `estimatedArrivalMinutes` | Number | ETA at 25 km/h |
| `nurseStatus` | Enum | pending/accepted/declined/expired |
| `patientStatus` | Enum | not_applicable/pending/accepted/declined |

### Booking (Updated)

New fields added to existing model:

| New Field | Type | Description |
|---|---|---|
| `matchingRequestId` | ObjectId→MatchingRequest | Link to matching request |
| `nurseOfferId` | ObjectId→NurseOffer | Which offer was accepted |
| `distanceKm` | Number | Distance nurse traveled |
| `destinationFee` | Number | Distance-based fee |
| `platformFee` | Number | Admin commission amount |

---

## 8. Flow Diagrams

### Complete Matching Flow

```
PATIENT                        SERVER                         NURSE(S)
  │                              │                              │
  │─── POST /matching/request ──>│                              │
  │    (serviceId, location)     │                              │
  │                              │── Phase 1: $geoNear ───────>│
  │                              │   Find online nurses nearby  │
  │                              │                              │
  │                              │── Phase 2: Score nurses ────>│
  │                              │   Distance + Rating + Exp    │
  │                              │                              │
  │                              │── Phase 3: Top 5 nurses ───>│
  │                              │                              │
  │                              │── Phase 4: Create offers ──>│
  │                              │                              │
  │<── 201 (offers_pending) ─────│── Socket: new_offer ───────>│ (×5)
  │                              │                              │
  │                              │         ┌───── 60s timer ───┤
  │                              │         │                    │
  │                              │<────────│── Accept/Decline ──│
  │                              │         │                    │
  │<── Socket: nurse_available ──│         └────────────────────┤
  │                              │                              │
  │── GET /patient-offers/:id ──>│                              │
  │<── Nurse list (up to 5) ─────│                              │
  │                              │                              │
  │── PUT /patient-offers/       │                              │
  │   :offerId/respond ─────────>│                              │
  │   { response: "accepted" }   │                              │
  │                              │── Create Booking ──────────>│
  │                              │── Create Transaction ──────>│
  │                              │── Decline other offers ────>│
  │                              │                              │
  │<── 200 (booking created) ────│── Socket: confirmed ───────>│
  │                              │                              │
```

### Status Transitions

```
MatchingRequest:  searching → offers_pending → nurse_accepted → accepted
                                    ↓                               ↓
                              no_nurses_found                   cancelled
                                                                  expired

NurseOffer (nurse):   pending → accepted → (patient decides)
                         ↓
                      declined / expired

NurseOffer (patient): not_applicable → pending → accepted
                                          ↓
                                       declined
```

---

## 9. Configuration

### Environment Variables

The service uses the same `.env` file as the rest of the backend:

| Variable | Default | Purpose |
|---|---|---|
| `JWT_SECRET_KEY` | `housepital_secret_key_2024` | JWT token signing |
| `PORT` | `3500` | Server port (shared with Socket.io) |
| `MONGODB_URI` | — | MongoDB connection string |

### Matching Config (in `matchingService.js`)

```javascript
const MATCHING_CONFIG = {
    DEFAULT_RADIUS_KM: 15,         // Max search radius
    MAX_NURSES_TO_MATCH: 5,        // Top N nurses to offer
    NURSE_OFFER_EXPIRY_SECONDS: 60 // Response window
};
```

### Pricing Config (in `pricingService.js`)

```javascript
const PRICING_CONFIG = {
    RATE_PER_KM: 3.50,            // EGP per kilometer
    MIN_DESTINATION_FEE: 15,       // Minimum fee (EGP)
    MAX_DESTINATION_FEE: 200,      // Maximum fee (EGP)
    PLATFORM_COMMISSION_RATE: 0.10, // 10%
    AVG_TRAVEL_SPEED_KMH: 25      // For ETA calculation
};
```

---

## 10. Testing

### Quick Test with cURL

**1. Get a price estimate:**
```bash
curl -X POST http://localhost:3500/api/matching/price-estimate \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"serviceId": "SERVICE_ID", "estimatedDistanceKm": 5}'
```

**2. Create a matching request:**
```bash
curl -X POST http://localhost:3500/api/matching/request \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "serviceId": "SERVICE_ID",
    "latitude": 30.0444,
    "longitude": 31.2357,
    "address": {"street": "Tahrir Square", "city": "Cairo", "state": "Cairo"},
    "nurseGenderPreference": "any",
    "timeOption": "asap"
  }'
```

**3. Get patient offers:**
```bash
curl http://localhost:3500/api/matching/patient-offers/REQUEST_ID \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**4. Accept a nurse offer:**
```bash
curl -X PUT http://localhost:3500/api/matching/patient-offers/OFFER_ID/respond \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"response": "accepted"}'
```

### Socket.io Test (from Flutter or JS client)

```javascript
import { io } from "socket.io-client";

const socket = io("http://localhost:3500", {
    auth: { token: "YOUR_JWT_TOKEN" }
});

// Listen for offers (nurse side)
socket.on("matching:new_offer", (data) => {
    console.log("New offer!", data);
});

// Listen for booking confirmation (both sides)
socket.on("matching:booking_confirmed", (data) => {
    console.log("Booking confirmed!", data);
});

// Update nurse location
socket.emit("nurse:update_location", {
    latitude: 30.0444,
    longitude: 31.2357
});
```

### Swagger UI

All matching endpoints are documented in Swagger at:
```
http://localhost:3500/api-docs
```

---

## Summary

- **Algorithm:** 4-phase weighted scoring (geospatial filter → score → rank → offer)
- **Pricing:** Service price (fixed) + destination fee (3.50 EGP/km) − 10% platform cut
- **Real-time:** Socket.io pushes offers instantly to nurses and patients
- **Patient sees:** Up to 5 nurse offers with name, photo, rating, experience, visits, price, ETA
- **Nurse sees:** Patient name, rating, service details, earnings, distance, time to respond
- **Files:** 6 new files + 2 modified files in the existing backend structure
