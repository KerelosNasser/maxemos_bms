<div align="center">
  <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Google%20Drive-4285F4?style=for-the-badge&logo=googledrive&logoColor=white" alt="Google Drive" />
  <img src="https://img.shields.io/badge/Gemini%20AI-8E75B2?style=for-the-badge&logo=google&logoColor=white" alt="Gemini AI" />
  
  <br />
  <br />

  <h1>📜 Maxemos BMS</h1>
  <h3>The Intelligent, Cloud-Native Manuscript Engine</h3>

  <p>
    An enterprise-grade Flutter application combining stunning vintage aesthetics with modern AI capabilities. Designed for secure, scalable document management and intelligent categorization using Google Cloud infrastructure.
  </p>

<a href="#features">Features</a> •
<a href="#architecture">Architecture</a> •
<a href="#getting-started">Getting Started</a> •
<a href="#security-considerations">Security</a>

</div>

---

## 🎯 Overview

**Maxemos BMS (Book Management System)** is a comprehensive document archive platform. It goes beyond standard PDF readers by integrating seamlessly with a serverless **Google Apps Script** backend for zero-cost cloud storage (via Google Drive) and leverages **Google Gemini AI** to act as an automated curator—analyzing contents, extracting metadata, and generating concise summaries.

Built natively in Flutter with a focus on high performance, clean architecture, and pristine UI/UX.

> **Note to Recruiters/Reviewers:** This project demonstrates advanced state management (`flutter_bloc`), secure backend communication without exposing raw GCP keys, robust UI composition with highly decoupled widgets, and complex asynchronous AI workflows.

<br/>

## ✨ Key Features

- **Decoupled Architecture**: Strictly separated layers (Presentation, Domain, Data) ensuring long-term maintainability.
- **Serverless Cloud Storage**: Securely uploads and streams PDFs directly to/from Google Drive via a custom Apps Script middleware.
- **AI-Driven Curation**: Utilizes Gemini 1.5 Flash to automatically consume manuscript excerpts and generate accurate categorized metadata.
- **Optimized UI/UX**: Features buttery-smooth Hero animations, custom vintage-themed `ThemeData`, and fully responsive grid/list layouts.
- **Bulletproof State Management**: Driven entirely by the BLoC pattern, ensuring predictable state transitions during simultaneous network and AI requests.
- **Production-Ready Logging**: Implements comprehensive, user-friendly console and error logging for easy debugging and crash analytics.

<br/>

## 🏗️ Architecture

Maxemos BMS utilizes a scalable directory structure enforcing separation of concerns:

```text
lib/
├── core/                   # Global configurations, routing, themes, and utility wrappers (Logger)
│   ├── config/env.dart     # Secure environment variable injection (flutter_dotenv)
│   └── services/           # Wrappers for external SDKs (Notifications, Gemini API)
├── data/
│   ├── models/             # Strongly typed data models (Book.dart)
│   └── services/           # Data fetching logic (DriveApiService)
└── presentation/
    ├── bloc/               # Business logic components representing UI state flows
    ├── screens/            # Top-level routing destinations (Dashboard, Details, Reader)
    └── widgets/            # Modular, highly reusable UI components (BookCard, DetailRows)
```

<br/>

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** `>= 3.11.0`
- A **Google Drive** Account (for the backend script)
- A **Google Gemini API Key**

### 1. Secure Environment Configuration

Clone the repository and install dependencies:

```bash
flutter pub get
```

This project enforces strict security by injecting secrets via an `.env` file at runtime. **Never commit your `.env` to version control.**

1. Copy the template:
   ```bash
   cp .env.example .env
   ```
2. Populate the `.env` file:

   ```env
   # Your customized Google Apps Script deployment URL
   DRIVE_API_URL=https://script.google.com/macros/s/YOUR_SCRIPT_ID/exec

   # Your Google AI Studio API Key
   GEMINI_API_KEY=your_gemini_api_key_here

   # A secure, random string matching your Google Apps Script configuration
   SCRIPT_SECRET_KEY=your_secure_randomly_generated_secret
   ```

### 2. Backend Setup (Google Apps Script)

Instead of exposing a raw GCP Service Account in the client, we use Google Apps Script as a secure middleware.

1. Navigate to [Google Apps Script](https://script.google.com).
2. Create a new project and replace the default code with the contents of `google_apps_script.js`.
3. Set your target `FOLDER_ID` and ensure the `EXPECTED_SECRET` precisely matches your `.env`'s `SCRIPT_SECRET_KEY`.
4. Deploy the script as a **Web App** (Execute as: "Me", Access: "Anyone").
5. Copy the generated URL into your `.env` `DRIVE_API_URL`.

### 3. Build & Run

Run the application on your preferred emulator or physical device:

```bash
flutter run --release
```

<br/>

## 🔒 Security Considerations

- **No Hardcoded Secrets**: Implementation of `flutter_dotenv` guarantees no sensitive tokens are compiled into the binary source code.
- **Middleware Authentication**: The Apps Script backend verifies a shared `SCRIPT_SECRET_KEY` before processing any CRUD operations, rejecting unauthorized traffic.
- **Safeguarded State**: Uncaught asynchronous exceptions are routed through the `logger` instances rather than crashing the Flutter engine, maintaining app stability.

---

<div align="center">
  <i>Engineered with excellence by Keron</i>
</div>
