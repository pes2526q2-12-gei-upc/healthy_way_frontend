import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../shared/models/chat_message.dart';
import 'token_service.dart';

/// Servei singleton per gestionar les crides a la API de xats
class ChatService {
  final http.Client client;
  static final ChatService _instance = ChatService._internal();

  factory ChatService({http.Client? client}) {
    if (client != null) {
      return ChatService._internal(client: client);
    }
    return _instance;
  }

  ChatService._internal({http.Client? client}) : client = client ?? http.Client();

  final String baseUrl = 'http://nattech.fib.upc.edu:40540/api/v1';

  /// Obté tots els missatges d'un xat
  /// GET /api/v1/chats/messages?chatId={chatId}
  Future<List<ChatMessage>> getMessages(int chatId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/chats/messages?chatId=$chatId'),
      headers: {'Authorization': 'Bearer ${await SecureStorageService().getToken()}'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> messagesJson = json['messages'] ?? [];
      return messagesJson
          .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
          .toList();
    } else {
      debugPrint('Error al obtenir missatges: ${response.statusCode}');
      debugPrint('Missatge: ${response.body}');
      return [];
    }
  }

  /// Obté missatges d'un xat d'equip (historial)
  /// GET /api/v1/chats/teams/{teamId}/messages
  Future<List<ChatMessage>> getTeamMessages(String teamId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/chats/teams/${Uri.encodeComponent(teamId)}/messages'),
      headers: {'Authorization': 'Bearer ${await SecureStorageService().getToken()}'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      // La resposta pot venir com a llista directa o dins d'un camp 'messages'
      if (json is List) {
        return json
            .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
            .toList();
      } else if (json is Map && json.containsKey('messages')) {
        final List<dynamic> messagesJson = json['messages'] ?? [];
        return messagesJson
            .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
            .toList();
      }
      return [];
    } else {
      debugPrint('Error al obtenir missatges d\'equip: ${response.statusCode}');
      debugPrint('Missatge: ${response.body}');
      return [];
    }
  }

  /// Envia un missatge al xat
  /// POST /api/v1/chats/
  /// Body: { chatId, senderId, content, datetime }
  Future<bool> sendMessage({
    required int chatId,
    required int senderId,
    required String content,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/chats/'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${await SecureStorageService().getToken()}'},
      body: jsonEncode({
        'chatId': chatId,
        'senderId': senderId,
        'content': content,
        'datetime': DateTime.now().toUtc().toIso8601String(),
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      debugPrint('Error en enviar missatge: ${response.statusCode}');
      debugPrint('Missatge: ${response.body}');
      return false;
    }
  }

  /// Obté missatges nous des d'una data
  /// GET /api/v1/chats/messages/since?chatId={chatId}&datetime={datetime}
  Future<List<ChatMessage>> getMessagesSince(int chatId, DateTime since) async {
    final response = await client.get(
      Uri.parse(
        '$baseUrl/chats/messages/since?chatId=$chatId&datetime=${since.toUtc().toIso8601String()}',
      ),
      headers: {'Authorization': 'Bearer ${await SecureStorageService().getToken()}'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> messagesJson = json['messages'] ?? [];
      return messagesJson
          .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
          .toList();
    } else {
      debugPrint('Error al obtenir missatges nous: ${response.statusCode}');
      return [];
    }
  }
}
