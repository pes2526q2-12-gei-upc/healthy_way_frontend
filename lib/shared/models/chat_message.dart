/// Model que reflecteix el ChatMessageDTO de la API
class ChatMessage {
  final String senderUsername;
  final String content;
  final DateTime timestamp;

  const ChatMessage({
    required this.senderUsername,
    required this.content,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      senderUsername: json['sender_username'] ?? '',
      content: json['content'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender_username': senderUsername,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
