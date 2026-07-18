import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/quest.dart';

class QuestService {
  static String get _baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';

  static Future<List<Quest>> fetchQuests() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/quests'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load quests (${response.statusCode})');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => Quest.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
