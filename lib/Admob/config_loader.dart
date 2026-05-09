// lib/comman/featchdata/config_loader.dart
import 'dart:convert';
import 'package:promptseen/Admob/app_config.dart';
import 'package:http/http.dart' as http;

class ConfigLoader {
  // Always fetch from this URL
  static const String url = 'https://promptseen.com/promptseenapp/json.json';

  // Fetch on app open; no caching to disk
  static Future<void> load() async {
    try {
      final resp = await http
          .get(Uri.parse(url), headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200 && resp.body.isNotEmpty) {
        final map = jsonDecode(resp.body) as Map<String, dynamic>;
        print(map);
        AppConfig.applyFromJson(map);
      } else {
        // Optionally clear values if response invalid:
        // AppConfig.reset();
      }
    } catch (e) {
      // Network/parse error; decide policy:
      // keep previous in-memory values OR reset to defaults
      // AppConfig.reset();
    }
  }
}
