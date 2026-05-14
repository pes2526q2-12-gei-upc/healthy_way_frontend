import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/foundation.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;
  final String _socketUrl = 'http://nattech.fib.upc.edu:40540/api/v1';

  bool get isConnected => _socket?.connected ?? false;

  void connect(String token) {
    if (_socket != null) {
      debugPrint('Socket ja inicialitzat, desconectant per refrescar...');
      _socket!.disconnect();
    }

    debugPrint('Connectant al socket: $_socketUrl');
    
    _socket = io.io(_socketUrl, io.OptionBuilder()
      .setTransports(['websocket'])
      .setAuth({
        'token': 'Bearer $token',
      })
      .enableAutoConnect()
      .build());

    _socket!.onConnect((_) {
      debugPrint('Socket connectat correctament: ${_socket!.id}');
    });

    _socket!.onConnectError((err) {
      debugPrint('Socket error de conexió: $err');
      if (err.toString().contains('auth') || err.toString().contains('Token')) {
        debugPrint('Error d\'autenticació al socket. Cal revisar el token.');
        // Aquí podríem disparar un callback o esdeveniment per fer logout
      }
    });

    _socket!.onDisconnect((_) {
      debugPrint('Socket desconectat');
    });

    _socket!.on('error', (err) {
      debugPrint('Socket Error: $err');
    });
    
    _socket!.connect();
  }

  void disconnect() {
    debugPrint('Desconectant socket...');
    _socket?.disconnect();
    _socket = null;
  }

  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  void off(String event) {
    _socket?.off(event);
  }
}
