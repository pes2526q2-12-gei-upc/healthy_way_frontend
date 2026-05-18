import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:healthy_way_frontend/core/services/chat_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  group('ChatService Tests', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    FlutterSecureStorage.setMockInitialValues({});

    test('getTeamMessages() should return list of ChatMessage on 200', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.queryParameters['teamId'], 'TeamA');
        
        final jsonResponse = {
          'messages': [
            {
              'sender_username': 'user1',
              'content': 'Hi',
              'timestamp': '2023-10-27T10:00:00Z'
            }
          ]
        };
        return http.Response(jsonEncode(jsonResponse), 200);
      });

      final service = ChatService(client: mockClient);
      final messages = await service.getTeamMessages('TeamA');

      expect(messages.length, 1);
      expect(messages[0].senderUsername, 'user1');
    });

    test('sendMessage() should return true on 201', () async {
      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body);
        expect(body['senderUsername'], 'user1');
        expect(body['content'], 'Hello');
        return http.Response('', 201);
      });

      final service = ChatService(client: mockClient);
      final success = await service.sendMessage(
        senderUsername: 'user1',
        content: 'Hello',
      );

      expect(success, true);
    });

    test('getTeamMessages() should handle plain list response', () async {
      final mockClient = MockClient((request) async {
        final jsonResponse = [
          {
            'sender_username': 'user2',
            'content': 'Hey',
            'timestamp': '2023-10-27T11:00:00Z'
          }
        ];
        return http.Response(jsonEncode(jsonResponse), 200);
      });

      final service = ChatService(client: mockClient);
      final messages = await service.getTeamMessages('TeamB');

      expect(messages.length, 1);
      expect(messages[0].senderUsername, 'user2');
    });
  });
}
