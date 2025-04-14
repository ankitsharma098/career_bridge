// lib/core/utils/config.dart
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class AppConfig {
  static String nlpApiEndpoint = '';
  static String nlpApiKey = '';

  static Future<void> load() async {
    try {
      final configString = await rootBundle.loadString('assets/config.json');
      final configData = json.decode(configString);

      nlpApiEndpoint =
          "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent" ??
              '';
      nlpApiKey = "AIzaSyD-kzFBnI6phwckhAvFBk65CpUfMUaxYdY" ?? '';
    } catch (e) {
      print('Error loading configuration: $e');
    }
  }
}
