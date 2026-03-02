import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/env.dart';
import '../utils/logger.dart';

class GeminiService {
  // Free tier models ordered generally from most stable/highest quota to previews
  static const List<String> _freeTierModels = [
    'gemini-2.5-flash',
    'gemini-2.5-flash-lite',
    'gemini-2.0-flash',
    'gemini-2.0-flash-lite',
    'gemini-2.0-flash-001',
    'gemini-2.0-flash-lite-001',
    'gemini-flash-latest',
    'gemini-flash-lite-latest',
    'gemini-3-flash-preview',
    'gemini-3.1-pro-preview',
    'gemini-3.1-pro-preview-customtools',
    'gemini-3-pro-preview',
    'gemini-2.5-pro',
    'gemini-pro-latest',
    'gemma-3-27b-it',
    'gemma-3-12b-it',
    'gemma-3-4b-it',
    'gemma-3-1b-it',
    'gemma-3n-e4b-it',
    'gemma-3n-e2b-it',
    'gemini-2.5-flash-lite-preview-09-2025',
    'gemini-robotics-er-1.5-preview',
    'nano-banana-pro-preview',
    'deep-research-pro-preview-12-2025',
    'gemini-2.5-flash-image',
    'gemini-3-pro-image-preview',
    'gemini-3.1-flash-image-preview',
    'gemini-2.5-computer-use-preview-10-2025',
    'gemini-2.5-flash-preview-tts',
    'gemini-2.5-pro-preview-tts',
  ];

  static Future<GenerateContentResponse> _generateWithFallback(
    String prompt,
    Duration timeout,
  ) async {
    if (Env.geminiApiKey.isEmpty) {
      throw Exception('Gemini API Key is not configured in the environment.');
    }

    Exception? lastException;

    for (final modelName in _freeTierModels) {
      try {
        final model = GenerativeModel(
          model: modelName,
          apiKey: Env.geminiApiKey,
        );

        final response = await model
            .generateContent([Content.text(prompt)])
            .timeout(timeout);

        return response;
      } catch (e) {
        logger.w(
          'Gemini model $modelName failed or quota exceeded: $e. Switching to next model...',
        );
        lastException = e is Exception ? e : Exception(e.toString());
      }
    }

    logger.e('All Gemini models exhausted or failed.');
    throw lastException ?? Exception('All Gemini models failed.');
  }

  static Future<Map<String, dynamic>> generateMetadata(String title) async {
    final prompt =
        '''
You are a highly knowledgeable and respected Coptic Orthodox Church Father. 
Analyze the book/manuscript titled: "$title".
Provide a short summary (max 3 sentences) and exactly 3 relevant genre categories. 
Important Rules:
1. Speak in clear, eloquent, and highly accurate Egyptian Arabic suitable for Coptic Orthodox teachings.
2. Ensure there are absolutely no theological mistakes and do not rely on unhelpful resources. The text must be well-reviewed like an authentic Coptic Orthodox father wrote it.
3. Respond ONLY in valid, strict JSON format with no markdown formatting or backticks around it, and the values must be in Egyptian Arabic.
Example format: {"summary": "هذا الكتاب العظيم يشرح...", "categories": ["لاهوت", "تاريخ الكنيسة", "سير قديسين"]}
''';

    try {
      final response = await _generateWithFallback(
        prompt,
        const Duration(seconds: 30),
      );

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
    final prompt =
        '''
You are a highly knowledgeable and respected Coptic Orthodox Church Father.
Summarize the following excerpt from pages $startPage to $endPage.
Important Rules:
1. Provide a highly accurate, concise summary in eloquent Egyptian Arabic.
2. Your response must be deeply rooted in Coptic Orthodox theology with zero room for errors.
3. Keep the tone spiritual, well-reviewed, and respectful. Do not rely on outside unhelpful resources.

EXCERPT:
$excerptText
''';

    try {
      final response = await _generateWithFallback(
        prompt,
        const Duration(seconds: 45),
      );

      return response.text ?? 'No summary generated.';
    } catch (e) {
      logger.e('Failed to summarize excerpt via Gemini AI: $e');
      throw Exception('Failed to summarize excerpt via Gemini AI: $e');
    }
  }
}
