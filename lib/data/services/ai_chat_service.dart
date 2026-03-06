import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ai_chat_session.dart';

class AiChatService {
  static const String _key = 'ai_chat_sessions';

  static Future<List<AiChatSession>> getAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => AiChatSession.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveSession(AiChatSession session) async {
    final sessions = await getAllSessions();
    final index = sessions.indexWhere((s) => s.id == session.id);

    if (index >= 0) {
      sessions[index] = session;
    } else {
      sessions.insert(0, session);
    }
    await _persist(sessions);
  }

  static Future<void> removeSession(String id) async {
    final sessions = await getAllSessions();
    sessions.removeWhere((s) => s.id == id);
    await _persist(sessions);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<void> _persist(List<AiChatSession> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(sessions.map((s) => s.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }
}
