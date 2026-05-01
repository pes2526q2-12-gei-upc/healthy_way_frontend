import 'package:flutter_test/flutter_test.dart';
import 'package:healthy_way_frontend/shared/models/chat_message.dart';

void main() {
  group('ChatMessage Model Tests', () {
    test('fromJson() should parse snake_case correctly', () {
      final json = {
        'sender_username': 'testuser',
        'content': 'Hello world',
        'timestamp': '2023-10-27T10:00:00Z',
      };

      final message = ChatMessage.fromJson(json);

      expect(message.senderUsername, 'testuser');
      expect(message.content, 'Hello world');
      expect(message.timestamp.isUtc, true);
      expect(message.timestamp.year, 2023);
    });

    test('fromJson() should parse camelCase correctly (fallback)', () {
      final json = {
        'senderUsername': 'testuser',
        'content': 'Hello world',
        'datetime': '2023-10-27T10:00:00Z',
      };

      final message = ChatMessage.fromJson(json);

      expect(message.senderUsername, 'testuser');
      expect(message.timestamp.year, 2023);
    });

    test('toJson() should return snake_case map', () {
      final now = DateTime.now();
      final message = ChatMessage(
        senderUsername: 'testuser',
        content: 'Hello',
        timestamp: now,
      );

      final json = message.toJson();

      expect(json['sender_username'], 'testuser');
      expect(json['content'], 'Hello');
      expect(json['timestamp'], now.toIso8601String());
    });
  });
}
