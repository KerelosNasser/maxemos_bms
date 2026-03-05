<div align="center">
  <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Google%20Drive-4285F4?style=for-the-badge&logo=googledrive&logoColor=white" alt="Google Drive" />
  <img src="https://img.shields.io/badge/Gemini%20AI-8E75B2?style=for-the-badge&logo=google&logoColor=white" alt="Gemini AI" />
  <img src="https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite" />
  
  <br />
  <br />

  <h1>📜 Maxemos BMS (مدرسة الروح القدس)</h1>
  <h3>The Intelligent, Cloud-Native Manuscript & Document Engine</h3>

  <p>
    An enterprise-grade Flutter application combining stunning vintage aesthetics with modern AI capabilities. Designed for secure, scalable document management, intelligent categorization, targeted OCR search, and interactive AI reading companions.
  </p>

<a href="#features">Features</a> •
<a href="#technical-highlights">Technical Highlights</a> •
<a href="#architecture">Architecture</a> •
<a href="#getting-started">Getting Started</a>

</div>

---

## 🎯 Overview

**Maxemos BMS (Book Management System)** is a comprehensive, feature-rich document archive platform and advanced PDF reader. It elegantly merges a bespoke vintage UI with cutting-edge capabilities, turning static manuscript consumption into an interactive, AI-assisted research experience.

It seamlessly integrates with a serverless **Google Apps Script** backend for zero-cost cloud storage (via Google Drive), leverages **Google Gemini AI** as an embedded reading companion, and features a robust **OCR engine** optimized for hard-to-parse languages like Arabic.

> **Note to Reviewers:** This project demonstrates advanced state management (`flutter_bloc`), secure backend communication (without exposing GCP keys), sophisticated offline caching, deeply integrated AI workflows, and complex UI composition (custom paints, advanced PDF rendering overrides).

<br/>

## ✨ Key Features

### 🤖 "Ask AI" Reading Companion

- **Contextual AI Chat**: Select any text within a PDF and instantly invoke an overlay to discuss, summarize, or translate the manuscript with Google Gemini 1.5 Flash.
- **Typewriter UI & Stable State**: Real-time streaming responses with custom typewriter animations, retaining chat history and scroll state flawlessly across sessions.

### 🔍 Advanced Arabic OCR Search Engine

- **Visual Text Retrieval**: Bypasses the limitations of standard PDF text layers by utilizing **Google ML Kit** and **Tesseract OCR**.
- **Precise Highlighting**: Calculates approximate `lineRatio` positions from OCR bounds and rendering custom visual highlight strips exactly over the targeted text on the PDF canvas.

### 📚 Sermon Preparation & Deep Highlighting

- **Custom Folders & Tagging**: Highlight important excerpts and categorize them into custom user-defined folders (e.g., specific sermon topics or research subjects).
- **Exportable Dashboards**: Dedicated UI to manage collected research, review highlights by folder, and easily export them.

### ⚡ Bulletproof Offline Capabilities

- **Database Caching**: Fully functional without network connectivity. Employs `sqflite` and `shared_preferences` to cache PDF binaries, cover art, and metadata locally.
- **Seamless Resumption**: Auto-saves the last viewed page and visual state for an uninterrupted reading flow upon return.

### ☁️ Serverless Google Drive Backend

- **Zero-Cost Scalability**: Securely streams, uploads, and queries documents directly from Google Drive using a secure, custom Google Apps Script middleware layer instead of a traditional dedicated backend.

### 🎨 Pristine "Vintage Ink" UI

- Built with a mesmerizing, dark-themed vintage aesthetic. Utilizes buttery-smooth Hero animations, highly responsive grids, and typography specifically tailored for prolonged reading comfort.

<br/>

## 🛠️ Technical Highlights

- **Architecture**: Strictly decoupled Domain, Data, and Presentation layers using clean architectural principles.
- **State Management**: Driven entirely by the **BLoC/Cubit** pattern ensuring predictable UI rendering even during turbulent network/AI state changes.
- **Security**: Strict runtime environment variable injection (`flutter_dotenv`) ensures no raw API keys are ever committed.
- **Production-Ready**: Comprehensive crash analytics, error logging (`logger`), network permission handling, and robust build setups for Android and iOS.

<br/>

## 🏗️ Project Structure

Maxemos BMS utilizes a scalable directory structure:

```text
lib/
├── core/                   # Global configs, theming, routing, and utility wrappers
│   ├── config/env.dart     # Secure environment variables
│   └── services/           # External SDK wrappers (GeminiService, Logging)
├── data/
│   ├── models/             # Strongly typed data (Book, Highlight, OcrMatch)
│   └── services/           # Data fetching and caching (DriveApiService, PdfSearchIndexer)
└── presentation/
    ├── bloc/               # Business logic components (PdfReaderBloc, DashboardCubit)
    ├── screens/            # Top-level routing (Dashboard, Reader, BookDetails)
    └── widgets/            # Reusable UI (AskAiOverlaySheet, TypewriterText, BookCard)
```

<br/>

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** `>= 3.11.0`
- A **Google Drive** Account (for the backend dataset)
- A **Google Gemini API Key**

### 1. Secure Environment Configuration

Clone the repository and install dependencies:

```bash
flutter pub get
```

Create a `.env` file in the root directory (never commit this file):

```env
# Your Google Apps Script deployment URL
DRIVE_API_URL=https://script.google.com/macros/s/YOUR_SCRIPT_ID/exec

# Your Google AI Studio API Key
GEMINI_API_KEY=your_gemini_api_key_here

# A secure random string to authenticate Apps Script requests
SCRIPT_SECRET_KEY=your_secure_randomly_generated_secret
```

### 2. Backend Setup (Google Apps Script)

We use Google Apps Script as a secure middleware to prevent exposing GCP Service Accounts in the client app.

1. Navigate to [Google Apps Script](https://script.google.com).
2. Create a new project and replace the default code with your `google_apps_script.js` equivalent.
3. Configure your target `FOLDER_ID` and ensure the `EXPECTED_SECRET` precisely matches your `.env`'s `SCRIPT_SECRET_KEY`.
4. Deploy the script as a **Web App** (Execute as: "Me", Access: "Anyone").
5. Copy the deployment URL into your `.env` `DRIVE_API_URL`.

### 3. Build & Run

Run the application on an emulator or a physical device:

```bash
flutter run --release
```

---

<div align="center">
  <i>Engineered with excellence by Keron</i>
</div>
