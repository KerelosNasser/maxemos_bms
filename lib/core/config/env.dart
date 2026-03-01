class Env {
  // Using dart-define to securely inject configuration at compile-time.
  // Example build command: flutter build apk --dart-define=DRIVE_API_URL="your-url" --dart-define=GEMINI_API_KEY="your-key"

  static const String driveApiUrl = String.fromEnvironment(
    'DRIVE_API_URL',
    defaultValue: 'https://script.google.com/macros/s/AKfycbxOi9_lNypXkC5B6fyp8zVORuOHZfj_OXf2NJ0QXOIDWigMyHrFjXs_L90M_951YNIr/exec', // Fallback placeholder
  );

  static const String geminiApiKey = String.fromEnvironment(
    'AIzaSyBRf4LMERSDLMcIPKMnh4LRD-3OFsreTa0',
    defaultValue: '',
  );

  static const String scriptSecretKey = String.fromEnvironment(
    'SCRIPT_SECRET_KEY',
    defaultValue: 'maxemos123', // Dummy fallback, do not use in prod
  );
}
