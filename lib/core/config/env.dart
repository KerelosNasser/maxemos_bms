import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  // Uses flutter_dotenv to load environment variables from the .env file.

  static String get driveApiUrl => dotenv.env['DRIVE_API_URL'] ?? '';

  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static String get scriptSecretKey => dotenv.env['SCRIPT_SECRET_KEY'] ?? '';
}
