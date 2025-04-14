// lib/features/voice_system/services/nlp_services.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NLPService {
  // Using a simple intent matching system with fallback to cloud API
  final Map<String, List<String>> _intentPatterns = {};
  final String? _apiKey;
  final String? _apiEndpoint;

  NLPService({String? apiKey, String? apiEndpoint})
      : _apiKey = apiKey,
        _apiEndpoint = apiEndpoint;

  void registerIntent(String intentName, List<String> patterns) {
    _intentPatterns[intentName] = patterns;
  }

  // Basic intent matching using pattern recognition
  Future<DialogflowResponse> processText(String text,
      {String sessionId = ''}) async {
    final normalizedInput = text.toLowerCase().trim();

    // First try local pattern matching
    for (final intentEntry in _intentPatterns.entries) {
      for (final pattern in intentEntry.value) {
        if (normalizedInput.contains(pattern.toLowerCase())) {
          debugPrint('Local match found: ${intentEntry.key}');
          return DialogflowResponse(
            intent: intentEntry.key,
            confidence: 0.8,
            parameters: _extractParameters(normalizedInput, intentEntry.key),
            fulfillmentText: '',
            allRequiredParamsPresent: true,
          );
        }
      }
    }

    // If no local match and we have API credentials, try cloud service
    if (_apiKey != null &&
        _apiKey!.isNotEmpty &&
        _apiEndpoint != null &&
        _apiEndpoint!.isNotEmpty) {
      try {
        debugPrint('No local match, trying cloud NLP API');
        return await _processWithCloudAPI(normalizedInput, sessionId);
      } catch (e) {
        debugPrint('Error calling NLP API: $e');
      }
    } else {
      debugPrint('No API credentials available for cloud NLP');
    }

    // No match found
    debugPrint('No intent match found for: "$normalizedInput"');
    return DialogflowResponse(
      intent: '',
      confidence: 0.0,
      parameters: {},
      fulfillmentText: '',
      allRequiredParamsPresent: false,
    );
  }

  Map<String, dynamic> _extractParameters(String text, String intent) {
    // Simple parameter extraction based on intent
    // This is a placeholder - implement actual parameter extraction logic
    final Map<String, dynamic> params = {};

    if (intent.startsWith('navigation.')) {
      // Extract navigation parameters if any
      // Example: "go to profile of John" -> {"user": "John"}
      if (text.contains('of ')) {
        final parts = text.split('of ');
        if (parts.length > 1) {
          params['target'] = parts[1].trim();
        }
      }
    }

    return params;
  }

  Future<DialogflowResponse> _processWithCloudAPI(
      String text, String sessionId) async {
    try {
      final response = await http
          .post(
            Uri.parse(_apiEndpoint!),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': 'Analyze this text for intent: "$text"'}
                  ]
                }
              ],
              'generationConfig': {
                'temperature': 0.2,
                'maxOutputTokens': 1024,
              }
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Process Gemini API response structure
        // The structure will need to be adapted to your actual API response
        final responseText =
            data['candidates'][0]['content']['parts'][0]['text'];

        // Simple pattern to extract intent from response
        // This should be replaced with proper parsing logic for your API
        String intent = '';
        Map<String, dynamic> parameters = {};

        if (responseText.toLowerCase().contains('navigation')) {
          if (responseText.toLowerCase().contains('back')) {
            intent = 'navigation.goBack';
          } else if (responseText.toLowerCase().contains('home')) {
            intent = 'navigation.goHome';
          } else if (responseText.toLowerCase().contains('settings')) {
            intent = 'navigation.goToSettings';
          } else if (responseText.toLowerCase().contains('profile')) {
            intent = 'navigation.goToProfile';
          }
        }

        debugPrint('Cloud API detected intent: $intent');

        return DialogflowResponse(
          intent: intent,
          confidence: 0.6,
          parameters: parameters,
          fulfillmentText: responseText,
          allRequiredParamsPresent: true,
        );
      } else {
        throw Exception(
            'API request failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('API processing error: $e');
      throw Exception('Failed to process text with API: $e');
    }
  }
}

class DialogflowResponse {
  final String intent;
  final double confidence;
  final Map<String, dynamic> parameters;
  final String fulfillmentText;
  final bool allRequiredParamsPresent;

  DialogflowResponse({
    required this.intent,
    required this.confidence,
    required this.parameters,
    required this.fulfillmentText,
    required this.allRequiredParamsPresent,
  });
}
