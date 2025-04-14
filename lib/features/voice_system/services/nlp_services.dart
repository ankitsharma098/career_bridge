import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NLPService {
  final Map<String, List<String>> _intentPatterns = {};
  final String? _apiKey;
  final String? _apiEndpoint;

  final double _localMatchThreshold = 0.7;
  final double _fuzzyMatchThreshold = 0.5;

  final List<String> _recentIntents = [];
  final int _maxRecentIntents = 5;

  NLPService({String? apiKey, String? apiEndpoint})
      : _apiKey = apiKey,
        _apiEndpoint = apiEndpoint;

  void registerIntent(String intentName, List<String> patterns) {
    _intentPatterns[intentName] = patterns;
  }

  Future<DialogflowResponse> detectIntent(String text,
      {String sessionId = ''}) async {
    final normalizedInput = text.toLowerCase().trim();
    final Map<String, double> potentialMatches = {};

    // Local matching logic
    for (final intentEntry in _intentPatterns.entries) {
      for (final pattern in intentEntry.value) {
        if (normalizedInput == pattern.toLowerCase()) {
          debugPrint('Exact match found: ${intentEntry.key}');
          _addToRecentIntents(intentEntry.key);
          return DialogflowResponse(
            intent: intentEntry.key,
            confidence: 1.0,
            parameters: _extractParameters(normalizedInput, intentEntry.key),
            fulfillmentText: '',
            allRequiredParamsPresent: true,
          );
        }
        if (normalizedInput.contains(pattern.toLowerCase())) {
          potentialMatches[intentEntry.key] =
              _calculateMatchConfidence(normalizedInput, pattern);
        }
      }
      final patternWords = intentEntry.value
          .expand((pattern) => pattern.toLowerCase().split(' '))
          .toSet();
      final inputWords = normalizedInput.split(' ').toSet();
      final commonWords = patternWords.intersection(inputWords);
      if (commonWords.isNotEmpty) {
        final wordOverlapScore = commonWords.length / inputWords.length;
        if (wordOverlapScore > _fuzzyMatchThreshold) {
          potentialMatches[intentEntry.key] = wordOverlapScore;
        }
      }
    }

    if (potentialMatches.isNotEmpty) {
      final bestMatch =
          potentialMatches.entries.reduce((a, b) => a.value > b.value ? a : b);
      if (bestMatch.value >= _localMatchThreshold) {
        debugPrint(
            'Local match found: ${bestMatch.key} with confidence ${bestMatch.value}');
        _addToRecentIntents(bestMatch.key);
        return DialogflowResponse(
          intent: bestMatch.key,
          confidence: bestMatch.value,
          parameters: _extractParameters(normalizedInput, bestMatch.key),
          fulfillmentText: '',
          allRequiredParamsPresent: true,
        );
      }
    }

    // Try cloud API if no strong local match
    debugPrint('No strong local match, trying cloud NLP API');
    return await _processWithCloudAPI(normalizedInput, sessionId);
  }

  Future<DialogflowResponse> _processWithCloudAPI(
      String text, String sessionId) async {
    if (_apiKey == null ||
        _apiKey!.isEmpty ||
        _apiEndpoint == null ||
        _apiEndpoint!.isEmpty) {
      debugPrint('Cloud NLP API credentials missing');
      return DialogflowResponse(
        intent: '',
        confidence: 0.0,
        parameters: {},
        fulfillmentText: 'API credentials not configured',
        allRequiredParamsPresent: false,
      );
    }

    try {
      // Append API key as query parameter
      final uri = Uri.parse('$_apiEndpoint?key=$_apiKey');
      debugPrint('Calling cloud NLP API with endpoint: $uri');

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {
                      'text':
                          'Analyze this text for intent and return the intent name (e.g., navigation.goHome, navigation.goToProfile) or "unknown" if no intent is detected: "$text"'
                    }
                  ]
                }
              ],
              'generationConfig': {
                'temperature': 0.2,
                'maxOutputTokens': 100,
              }
            }),
          )
          .timeout(const Duration(seconds: 5));

      debugPrint('API response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseText =
            data['candidates'][0]['content']['parts'][0]['text'].trim();

        // Extract intent directly, assuming Gemini returns the intent name
        String intent = responseText == 'unknown' ? '' : responseText;
        Map<String, dynamic> parameters = _extractParameters(text, intent);

        debugPrint('Cloud API detected intent: $intent');
        if (intent.isNotEmpty) {
          _addToRecentIntents(intent);
        }
        return DialogflowResponse(
          intent: intent,
          confidence: 0.75,
          parameters: parameters,
          fulfillmentText: responseText,
          allRequiredParamsPresent: true,
        );
      } else {
        debugPrint(
            'API request failed: ${response.statusCode} - ${response.body}');
        throw Exception(
            'API request failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('API processing error: $e');
      // Fallback to local matching
      final potentialMatches = _findPotentialMatches(text);
      if (potentialMatches.isNotEmpty) {
        final bestMatch = potentialMatches.entries
            .reduce((a, b) => a.value > b.value ? a : b);
        if (bestMatch.value >= _fuzzyMatchThreshold) {
          debugPrint(
              'Falling back to fuzzy match: ${bestMatch.key} with confidence ${bestMatch.value}');
          _addToRecentIntents(bestMatch.key);
          return DialogflowResponse(
            intent: bestMatch.key,
            confidence: bestMatch.value,
            parameters: _extractParameters(text, bestMatch.key),
            fulfillmentText: '',
            allRequiredParamsPresent: true,
          );
        }
      }
      return DialogflowResponse(
        intent: '',
        confidence: 0.0,
        parameters: {},
        fulfillmentText: 'Failed to process with cloud API',
        allRequiredParamsPresent: false,
      );
    }
  }

  Map<String, double> _findPotentialMatches(String normalizedInput) {
    final Map<String, double> potentialMatches = {};
    for (final intentEntry in _intentPatterns.entries) {
      for (final pattern in intentEntry.value) {
        if (normalizedInput.contains(pattern.toLowerCase())) {
          potentialMatches[intentEntry.key] =
              _calculateMatchConfidence(normalizedInput, pattern);
        }
      }
      final patternWords = intentEntry.value
          .expand((pattern) => pattern.toLowerCase().split(' '))
          .toSet();
      final inputWords = normalizedInput.split(' ').toSet();
      final commonWords = patternWords.intersection(inputWords);
      if (commonWords.isNotEmpty) {
        final wordOverlapScore = commonWords.length / inputWords.length;
        if (wordOverlapScore > _fuzzyMatchThreshold) {
          potentialMatches[intentEntry.key] = wordOverlapScore;
        }
      }
    }
    return potentialMatches;
  }

  void _addToRecentIntents(String intent) {
    if (intent.isNotEmpty) {
      _recentIntents.insert(0, intent);
      if (_recentIntents.length > _maxRecentIntents) {
        _recentIntents.removeLast();
      }
    }
  }

  double _calculateMatchConfidence(String input, String pattern) {
    double score;
    if (input == pattern) {
      score = 1.0;
    } else if (input.startsWith(pattern)) {
      score = 0.9;
    } else if (input.endsWith(pattern)) {
      score = 0.85;
    } else {
      final patternWords = pattern.toLowerCase().split(' ');
      final inputWords = input.split(' ');
      int matchedWords = 0;
      for (final word in patternWords) {
        if (inputWords.contains(word)) {
          matchedWords++;
        }
      }
      score = matchedWords / patternWords.length * 0.8;
    }
    return score;
  }

  Map<String, dynamic> _extractParameters(String text, String intent) {
    final Map<String, dynamic> params = {};
    if (intent.startsWith('navigation.')) {
      if (text.contains(' to ')) {
        final parts = text.split(' to ');
        if (parts.length > 1) {
          String destination = parts[1].trim();
          final endWords = ['page', 'screen', 'section'];
          for (final word in endWords) {
            if (destination.endsWith(' $word')) {
              destination = destination.substring(
                  0, destination.length - word.length - 1);
              break;
            }
          }
          params['destination'] = destination;
        }
      }
      if (text.contains('of ')) {
        final parts = text.split('of ');
        if (parts.length > 1) {
          params['target'] = parts[1].trim();
        }
      }
    } else if (intent.contains('search')) {
      final searchTerms = text
          .replaceAll(RegExp(r'search for|search|look for|find'), '')
          .trim();
      if (searchTerms.isNotEmpty) {
        params['query'] = searchTerms;
      }
    }
    return params;
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
