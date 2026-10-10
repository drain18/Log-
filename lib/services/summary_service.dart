import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SummaryService {
  // Read API key from flutter_dotenv or compile-time environment fallback
  static String get _apiKey {
    try {
      final envKey = dotenv.env['GEMINI_API_KEY'];
      if (envKey != null && envKey.isNotEmpty) {
        debugPrint('--- SummaryService: Loaded GEMINI_API_KEY from dotenv (${envKey.substring(0, 4)}...) ---');
        return envKey;
      }
    } catch (e) {
      debugPrint('--- SummaryService: Error reading dotenv: $e ---');
    }
    const fallback = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    if (fallback.isNotEmpty) {
      debugPrint('--- SummaryService: Loaded GEMINI_API_KEY from dart-define ---');
    }
    return fallback;
  }

  static Future<String> summarize(String entryText, {String? apiKey}) async {
    final key = apiKey ?? _apiKey;
    if (key.isEmpty) {
      throw Exception('Gemini API key is not configured. Please set GEMINI_API_KEY in your .env file.');
    }

    if (entryText.trim().isEmpty) {
      return 'No content to summarize.';
    }

    // Using gemini-pro which is universally supported across all Google AI Studio free tier keys
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=$key',
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
