# InternGrow — Hospital Appointment System

> Task 5 of the InternGrow Mobile Development Internship.
> A healthcare appointment booking app built in Flutter, using GetX, Firebase Auth,
> real embedded video consultations via Jitsi Meet, QR appointment tokens, and PDF prescriptions.

🔗 **Live Demo (Web):** _coming soon_
📱 **Download APK:** _coming soon (see GitHub Releases)_

⚠️ **This is a portfolio/demo project, not a real clinical system.** No real doctors, no real
medical advice, and no PHI-compliance measures are implemented — it's built to demonstrate
mobile architecture and Firebase integration patterns for a healthcare-style app.

---

## ✨ Features

- [x] Doctor Listing
- [ ] Appointment Booking
- [ ] Patient Profile
- [ ] Medical History
- [ ] Notifications
- [x] Search Doctors
- [ ] Appointment History

### Upgrade Features
- [ ] Video Consultation UI (real Jitsi Meet integration)
- [ ] QR Appointment Token
- [ ] Prescription Viewer
- [ ] Firebase Authentication

---

## 🛠️ Tech Stack

| Category | Choice |
|---|---|
| Framework | Flutter (Dart) |
| State Management | GetX |
| Auth | Firebase Authentication |
| Doctor Data | RandomUser.me API + mock specialization/rating data |
| Video Consultation | Jitsi Meet (free public server) via webview_flutter |
| QR Codes | qr_flutter |
| PDF (Prescriptions) | pdf + printing |

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.3.0 or higher)
- A Firebase project

### Setup

1. Clone the repo
```bash
   git clone https://github.com/<your-username>/InternGrow_HospitalAppointmentApp.git
   cd InternGrow_HospitalAppointmentApp
```
2. Install dependencies
```bash
   flutter pub get
```
3. Connect Firebase (Auth)
4. Run
```bash
   flutter run
```

---

## 📌 Status

🚧 In active development as part of the InternGrow Internship (Task 5 of 6).