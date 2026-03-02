import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  // Read .env file directly
  final envFile = File('.env');
  if (!await envFile.exists()) {
    print('.env not found');
    return;
  }

  String apiKey = '';
  final lines = await envFile.readAsLines();
  for (var line in lines) {
    if (line.startsWith('GEMINI_API_KEY=')) {
      apiKey = line.split('=')[1].trim();
      break;
    }
  }

  if (apiKey.isEmpty) {
    print('No API key found in .env');
    return;
  }

  final url = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey',
  );
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final models = data['models'] as List;
    print('Available Generative Models:');
    for (var m in models) {
      if (m['supportedGenerationMethods']?.contains('generateContent') ==
          true) {
        print(
          '- ${m['name'].toString().replaceAll('models/', '')} (Tokens: ${m['inputTokenLimit']})',
        );
      }
    }
  } else {
    print('Failed to fetch models: ${response.statusCode} - ${response.body}');
  }
}
