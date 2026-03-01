import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/env.dart';
import '../utils/logger.dart';

class GeminiService {
  static Future<Map<String, dynamic>> generateMetadata(String title) async {
    if (Env.geminiApiKey.isEmpty) {
      throw Exception('Gemini API Key is not configured in the environment.');
    }

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: Env.geminiApiKey,
    );

    final prompt =
        '''
Analyze the book/manuscript titled: "$title". 
Provide a short summary (max 3 sentences) and exactly 3 relevant genre categories. 
Respond ONLY in valid, strict JSON format with no markdown formatting or backticks around it.
Example format: {"summary": "A great book.", "categories": ["Fiction", "Fantasy", "Magic"]}
''';

    try {
      final response = await model
          .generateContent([Content.text(prompt)])
          .timeout(const Duration(seconds: 30));

      String text = response.text ?? '{}';

      // Clean up potential markdown formatting that Gemini occasionally inserts
      text = text.replaceAll('```json', '').replaceAll('```', '').trim();

      final Map<String, dynamic> data = json.decode(text);
      return data;
    } catch (e) {
      logger.e('Failed to generate metadata from Gemini AI: $e');
      throw Exception('Failed to generate metadata from Gemini AI: $e');
    }
  }

  static Future<String> summarizeExcerpt(
    String excerptText,
    int startPage,
    int endPage,
  ) async {
    if (Env.geminiApiKey.isEmpty) {
      throw Exception('Gemini API Key is not configured in the environment.');
    }

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: Env.geminiApiKey,
    );

    final prompt =
        '''
You are an expert Arabic manuscript analyst. Please summarize the following excerpt taken from pages $startPage to $endPage.
Provide a highly accurate, concise summary in English. If the text is in Arabic, translate the core meaning and summarize it.

EXCERPT:
$excerptText
''';

    try {
      final response = await model
          .generateContent([Content.text(prompt)])
          .timeout(const Duration(seconds: 45));

      return response.text ?? 'No summary generated.';
    } catch (e) {
      logger.e('Failed to summarize excerpt via Gemini AI: $e');
      throw Exception('Failed to summarize excerpt via Gemini AI: $e');
    }
  }
}
