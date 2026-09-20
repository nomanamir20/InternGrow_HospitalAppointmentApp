# InternGrow — Hospital Appointment System

A Flutter-based healthcare appointment application designed to demonstrate a complete digital appointment workflow, including doctor discovery, appointment booking, patient profiles, medical history, appointment history, notifications, video consultations, QR appointment tokens, and prescription viewing.

The application uses Firebase Authentication for user accounts, RandomUser.me for demo doctor data, Jitsi Meet for video consultations, QR codes for appointment tokens, and PDF generation for prescription documents.

> Developed as Task 5 of the InternGrow Mobile Development Internship.

⚠️ **Portfolio/Demo Project:** This application is intended for educational and portfolio purposes only. It does not represent a real clinical system, does not provide medical advice, and does not implement production healthcare compliance or handling of real patient health information.


🔗 **Live Demo (Web):** _coming soon_
📱 **Download APK:** _coming soon (see GitHub Releases)_

⚠️ **This is a portfolio/demo project, not a real clinical system.** No real doctors, no real
medical advice, and no PHI-compliance measures are implemented — it's built to demonstrate
mobile architecture and Firebase integration patterns for a healthcare-style app.

---

## ✨ Features

- [x] Doctor Listing
- [x] Appointment Booking
- [x] Patient Profile
- [x] Medical History
- [x] Notifications
- [x] Search Doctors
- [x] Appointment History

### Upgrade Features
- [x] Video Consultation UI
- [x] QR Appointment Token
- [x] Prescription Viewer
- [ ] Firebase Authentication

### A note on Video Consultation

Real embedded Jitsi Meet video calls work natively on Android via `webview_flutter`. On Flutter
Web, browsers block camera/microphone access inside cross-origin iframes (a genuine browser
security boundary, not a workaround-able bug), so the web version opens the real Jitsi call in
a new browser tab instead — camera/mic permissions work normally there, since it's no longer
sandboxed. Both paths use the same free, public Jitsi server (meet.jit.si) — no account,
API key, or billing required either way.

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
## 👨‍💻 My Contribution

This project was independently designed and developed by me as part of the InternGrow Mobile Development Internship.

I was responsible for the complete development and integration of the application, including:

* Flutter UI and application development
* GetX state management
* Doctor discovery and search functionality
* Appointment booking workflows
* Patient profile and medical history
* Appointment history
* Firebase Authentication
* Notification functionality
* Jitsi Meet video consultation integration
* QR appointment token generation
* Prescription viewing and PDF generation
* RandomUser.me REST API integration for demo doctor data
* Application navigation and workflow integration
* Android and cross-platform functionality
* Testing, debugging, and overall application integration

## Screenshot

### Login / Authentication


<img width="372" height="416" alt="image" src="https://github.com/user-attachments/assets/a447030e-8137-46c0-874d-8edaad15b59c" />



### Doctor Listing


<img width="372" height="418" alt="image" src="https://github.com/user-attachments/assets/075c6776-fd00-40d6-8744-31886556ba87" />


### Doctor Search


<img width="373" height="418" alt="image" src="https://github.com/user-attachments/assets/f10eaf31-2349-4050-8df7-d31be9b753d7" />



### Appointment Booking


<img width="377" height="419" alt="image" src="https://github.com/user-attachments/assets/4b831551-f418-49be-b509-efa22de342b6" />



### Appointment History


<img width="376" height="419" alt="image" src="https://github.com/user-attachments/assets/0a7b344f-78a7-4cdd-85ab-bff571473aa1" />



### QR Appointment Token



<img width="375" height="420" alt="image" src="https://github.com/user-attachments/assets/c02e4d55-1ecb-405e-a3e8-7b48135e502f" />



### Video Consultation



<img width="368" height="416" alt="image" src="https://github.com/user-attachments/assets/80321bcc-3457-48c5-8bcc-ef76e5e4fc02" />



<img width="374" height="418" alt="image" src="https://github.com/user-attachments/assets/81dadb3e-aa46-416c-a30c-1ca85315377c" />


### Clone Command

git clone https://github.com/nomanamir20/InternGrow_HospitalAppointmentApp.git


## 📌 Status


✅ Complete — developed as Task 5 of the InternGrow Mobile Development Internship.

The application is currently maintained as a portfolio and demonstration project.
