import 'dart:convert';
import 'package:http/http.dart' as http;

/// Set this to your deployed HTTPS backend URL before release.
/// Never place an AI provider secret/API key inside the Android application.
const String suzaneBackendUrl = String.fromEnvironment(
  'SUZANE_BACKEND_URL',
  defaultValue: '',
);

class AiService {
  Future<String> sendMessage(List<Map<String, String>> history) async {
    if (suzaneBackendUrl.isEmpty) {
      throw Exception('Le serveur SUZANE n’est pas encore configuré.');
    }
    final uri = Uri.parse('$suzaneBackendUrl/api/chat');
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'messages': history}),
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode != 200) {
      throw Exception('Le serveur a répondu (${response.statusCode}).');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final answer = data['answer'] as String?;
    if (answer == null || answer.trim().isEmpty) {
      throw Exception('Le serveur a retourné une réponse vide.');
    }
    return answer;
  }
}
