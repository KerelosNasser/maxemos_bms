# Maxemos BMS (Book Management System)

A beautiful, vintage-themed Flutter application designed for managing, reading, and analyzing manuscripts and books. It uses Google Drive for storage and Gemini AI for automated categorization and summarization.

## Features

- **Vintage Aesthetics:** Immersive parchment designs and typography.
- **Drive Integration:** Seamlessly upload, sync, and manage PDFs via Google Drive.
- **AI Oracle:** Automatically generates categories and summaries using Gemini AI.
- **Integrated Reader:** Read and analyze PDFs directly within the app.

## Project Structure

The app follows a structured, modular approach:

- `lib/core/`: Theming, global utilities (like `logger`), config, and service wrappers.
- `lib/data/`: Data models and the Drive API service implementation.
- `lib/presentation/`: Screens, BLoCs for state management, and reusable UI widgets.

## Prerequisites

- Flutter SDK `^3.11.0`
- Access to a Google account for Apps Script deployment.
- A Gemini AI API Key.

## Setup Instructions

### 1. Environment Configuration

**Do not commit secrets to Git!** This application uses `flutter_dotenv` for handling secure environment variables.

1. Copy the example `.env` file:
   ```bash
   cp .env.example .env
   ```
2. Fill your `.env` file with the required production constraints:
   ```env
   DRIVE_API_URL=https://script.google.com/macros/s/.../exec
   GEMINI_API_KEY=your_gemini_api_key
   SCRIPT_SECRET_KEY=your_secure_randomly_generated_secret
   ```

### 2. Google Apps Script Deployment

To securely connect to Google Drive without enabling GCP's sensitive scopes directly:

1. Open [Google Apps Script](https://script.google.com).
2. Create a new project and paste the contents of `google_apps_script.js`.
3. Update specific placeholders (`FOLDER_ID` and `EXPECTED_SECRET`) inside the script. **Ensure `EXPECTED_SECRET` matches your `.env`'s `SCRIPT_SECRET_KEY`**.
4. Deploy as a "Web App", granting access to "Anyone". Copy the generated deployment URL into your `.env` file.

### 3. Running the App

Once your `.env` file is ready, build and run the application:

```bash
flutter pub get
flutter run
```

---

_Note: Developed with production-ready standards focusing on clean architecture, minimal dependencies, and strict security rules._
