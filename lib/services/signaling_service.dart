import 'dart:convert';
import 'dart:io';

/// Runs ONLY on the Director phone. Accepts connections from BOTH the
/// Pastor phone and the Crowd phone, distinguishing them by a "role"
/// each phone announces right after connecting.
class SignalingServer {
  HttpServer? _server;
  final Map<String, WebSocket> _sockets = {};
  void Function(String role, Map<String, dynamic> message)? onMessage;
  void Function(String role)? onClientConnected;
  void Function(String role)? onClientDisconnected;

  static const port = 8765;

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    _server!.listen((request) async {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        final socket = await WebSocketTransformer.upgrade(request);
        String? role;
        socket.listen(
          (data) {
            try {
              final msg = jsonDecode(data as String) as Map<String, dynamic>;
              if (msg['type'] == 'hello') {
                role = msg['role'] as String;
                _sockets[role!] = socket;
                onClientConnected?.call(role!);
                return;
              }
              if (role != null) onMessage?.call(role!, msg);
            } catch (_) {}
          },
          onDone: () {
            if (role != null) {
              _sockets.remove(role);
              onClientDisconnected?.call(role!);
            }
          },
        );
      }
    });
  }

  void send(String role, Map<String, dynamic> message) {
    _sockets[role]?.add(jsonEncode(message));
  }

  Future<void> stop() async {
    for (final s in _sockets.values) {
      await s.close();
    }
    await _server?.close(force: true);
  }
}

/// Runs on EACH camera phone (Pastor and Crowd both use this same class,
/// just with a different `role` string). Connects to the Director.
class SignalingClient {
  WebSocket? _socket;
  void Function(Map<String, dynamic> message)? onMessage;
  void Function()? onDisconnected;

  Future<void> connect(String directorIp, String role) async {
    _socket =
        await WebSocket.connect('ws://$directorIp:${SignalingServer.port}');
    _socket!.add(jsonEncode({'type': 'hello', 'role': role}));
    _socket!.listen(
      (data) {
        try {
          final msg = jsonDecode(data as String) as Map<String, dynamic>;
          onMessage?.call(msg);
        } catch (_) {}
      },
      onDone: () => onDisconnected?.call(),
    );
  }

  void send(Map<String, dynamic> message) {
    _socket?.add(jsonEncode(message));
  }

  Future<void> disconnect() async {
    await _socket?.close();
  }
}
