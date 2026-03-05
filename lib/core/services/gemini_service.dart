import 'dart:convert';
import 'package:http/http.dart' as http;
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

  static Future<String> _generateWithFallback(
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

        return response.text ?? '';
      } catch (e) {
        logger.w(
          'Gemini model $modelName failed or quota exceeded: $e. Switching to next model...',
        );
        lastException = e is Exception ? e : Exception(e.toString());
      }
    }

    logger.e(
      'All Gemini models exhausted or failed. Falling back to OpenRouter...',
    );

    if (Env.openRouterApiKey.isEmpty) {
      throw lastException ??
          Exception(
            'All Gemini models failed and OpenRouter API key is missing.',
          );
    }

    try {
      final response = await http
          .post(
            Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
            headers: {
              'Authorization': 'Bearer ${Env.openRouterApiKey}',
              'Content-Type': 'application/json',
              'HTTP-Referer': 'https://maxemosbms.local',
              'X-Title': 'Maxemos BMS',
            },
            body: jsonEncode({
              'model': 'meta-llama/llama-3.3-70b-instruct:free',
              'messages': [
                {'role': 'user', 'content': prompt},
              ],
            }),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final content = data['choices'][0]['message']['content'];
          return content?.toString() ?? '';
        }
      }
      throw Exception(
        'OpenRouter returned ${response.statusCode}: ${response.body}',
      );
    } catch (openRouterError) {
      logger.e('OpenRouter fallback also failed: $openRouterError');
      throw Exception(
        'Both Gemini and OpenRouter failed. Last Gemini error: $lastException. OpenRouter error: $openRouterError',
      );
    }
  }

  static Future<Map<String, dynamic>> generateMetadata(String title) async {
    final prompt =
        '''
أنت أب قبطي أرثوذكسي محترم وذو معرفة واسعة.
قم بتحليل الكتاب/المخطوطة أو الموضوع بعنوان: "$title".
قدم ملخصًا قصيرًا (بحد أقصى 3 جمل) و 3 فئات (تصنيفات) دقيقة ذات صلة.
قواعد هامة جداً:
1. يجب أن يكون الرد باللغة العربية فقط. ممنوع منعاً باتاً استخدام اللغة الإنجليزية في الملخص أو الفئات.
2. تأكد من عدم وجود أي أخطاء لاهوتية. يجب أن يبدو النص وكأنه مكتوب بواسطة أب قبطي أرثوذكسي مبدع.
3. يجب أن يكون الرد بصيغة JSON صحيحة تماماً وبدون أي علامات تنسيق (مثل Markdown) أو فواصل إضافية.
4. يجب أن تكون جميع القيم والنصوص داخل الـ JSON باللغة العربية 100%.

مثال للصيغة المطلوبة: {"summary": "هذا الكتاب العظيم يشرح بالتفصيل...", "categories": ["لاهوت", "تاريخ الكنيسة", "سير قديسين"]}
''';

    try {
      final responseText = await _generateWithFallback(
        prompt,
        const Duration(seconds: 30),
      );

      String text = responseText.isEmpty ? '{}' : responseText;

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
أنت أب قبطي أرثوذكسي محترم وذو معرفة واسعة.
قم بتلخيص النص أو المقتطف التالي من صفحة $startPage إلى صفحة $endPage.
قواعد هامة جداً:
1. قدم ملخصاً دقيقاً وموجزاً باللغة العربية بأسلوب روحي رصين. ممنوع كتابة أي كلمة باللغة الإنجليزية.
2. يجب أن تكون إجابتك متجذرة في اللاهوت القبطي الأرثوذكسي وبدون أي أخطاء عقائدية.
3. حافظ على نبرة روحية ومحترمة، ولا تعتمد على مصادر خارجية غير موثوقة.
4. الرد يجب أن يكون باللغة العربية 100%.

النص/المقتطف:
$excerptText
''';

    try {
      final responseText = await _generateWithFallback(
        prompt,
        const Duration(seconds: 45),
      );

      return responseText.isEmpty ? 'No summary generated.' : responseText;
    } catch (e) {
      logger.e('Failed to summarize excerpt via Gemini AI: $e');
      throw Exception('Failed to summarize excerpt via Gemini AI: $e');
    }
  }

  static Future<String> askQuestionAboutText({
    required String text,
    required String bookTitle,
    required String question,
  }) async {
    final prompt =
        '''
أنت أب قبطي أرثوذكسي محترم وذو معرفة واسعة.
القارئ يسألك سؤالاً عن النص التالي المأخوذ من كتاب "$bookTitle".
أجب عن سؤاله بوضوح وبأسلوب روحي رصين، معتمداً على النص المرفق وعلى تعاليم الكنيسة القبطية الأرثوذكسية الخالية من الأخطاء العقائدية.
يجب أن تكون إجابتك باللغة العربية 100%.

النص الذي قرأه المستخدم:
"$text"

سؤال المستخدم:
"$question"
''';

    try {
      final responseText = await _generateWithFallback(
        prompt,
        const Duration(seconds: 45),
      );

      return responseText.isEmpty
          ? 'عذراً، لم أتمكن من إيجاد إجابة.'
          : responseText;
    } catch (e) {
      logger.e('Failed to answer user question via Gemini AI: $e');
      throw Exception('Failed to answer user question via Gemini AI: $e');
    }
  }
}
