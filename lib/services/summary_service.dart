import 'dart:convert';
import 'package:http/http.dart' as http;

class SummaryService {
  // Read API key from compile-time environment or fallback
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  static Future<String> summarize(String entryText, {String? apiKey}) async {
    final key = apiKey ?? _apiKey;
    if (key.isEmpty) {
      throw Exception('Gemini API key is not configured. Please set GEMINI_API_KEY.');
    }

    if (entryText.trim().isEmpty) {
      return 'No content to summarize.';
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$key',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': 'Please provide a concise, insightful 1-2 sentence summary of the following journal entry:\n\n$entryText'
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      try {
        final candidate = data['candidates'][0];
        final content = candidate['content'];
        final parts = content['parts'][0];
        return parts['text'].toString().trim();
      } catch (e) {
        throw Exception('Failed to parse summary response from Gemini.');
      }
    } else {
      throw Exception('Gemini API error (${response.statusCode}): ${response.body}');
    }
  }
}
