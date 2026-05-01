import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../shared/models/chat_message.dart';
import 'token_service.dart';

/// Servei singleton per gestionar les crides a la API de xats
class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final String baseUrl = 'http://nattech.fib.upc.edu:40540/api/v1';

  /// Obté tots els missatges d'un equip
  /// GET /api/v1/chats/messages?teamId={teamId}
  Future<List<ChatMessage>> getTeamMessages(String teamId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chats/messages?teamId=${Uri.encodeComponent(teamId)}'),
      headers: {
        'Authorization': 'Bearer ${await SecureStorageService().getToken()}'
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      List<dynamic> messagesJson = [];
      if (json is List) {
        messagesJson = json;
      } else if (json is Map && json.containsKey('messages')) {
        messagesJson = json['messages'] ?? [];
      }
      return messagesJson
          .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
          .toList();
    } else {
      debugPrint('Error al obtenir missatges: ${response.statusCode}');
      debugPrint('Missatge: ${response.body}');
      return [];
    }
  }

  /// Envia un missatge al xat
  /// POST /api/v1/chats/
  /// Body: { senderUsername, content, datetime }
  Future<bool> sendMessage({
    required String senderUsername,
    required String content,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chats/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await SecureStorageService().getToken()}'
      },
      body: jsonEncode({
        'senderUsername': senderUsername,
        'content': content,
        'datetime': DateTime.now().toUtc().toIso8601String(),
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      debugPrint('Error en enviar missatge: ${response.statusCode}');
      debugPrint('Missatge: ${response.body}');
      return false;
    }
  }

  /// Obté missatges nous des d'una data
  /// GET /api/v1/chats/messages/since?teamId={teamId}&since={since}
  Future<List<ChatMessage>> getMessagesSince(String teamId, DateTime since) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/chats/messages/since?teamId=${Uri.encodeComponent(teamId)}&since=${since.toUtc().toIso8601String()}',
      ),
      headers: {
        'Authorization': 'Bearer ${await SecureStorageService().getToken()}'
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      List<dynamic> messagesJson = [];
      if (json is List) {
        messagesJson = json;
      } else if (json is Map && json.containsKey('messages')) {
        messagesJson = json['messages'] ?? [];
      }
      return messagesJson
          .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
          .toList();
    } else {
      debugPrint('Error al obtenir missatges nous: ${response.statusCode}');
      return [];
    }
  }
}
