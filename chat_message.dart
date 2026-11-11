class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.createdAt,
  });

  final String text;
  final bool isUser;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'text': text,
    'isUser': isUser,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    text: json['text'] as String? ?? '',
    isUser: json['isUser'] as bool? ?? false,
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
}
