import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';

class ChatStorage {
  late SharedPreferences _prefs;
  static const _key = 'suzane_chat_history_v1';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  List<ChatMessage> loadMessages() {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => ChatMessage.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveMessages(List<ChatMessage> messages) async {
    await _prefs.setString(
      _key,
      jsonEncode(messages.map((message) => message.toJson()).toList()),
    );
  }

  Future<void> clear() => _prefs.remove(_key);
}
