import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/event.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final Function(Event) onEventReceived;
  final Function(String) onError;

  WebSocketService({
    required this.onEventReceived,
    required this.onError,
  });

  void connect(String token) {
    try {
      final uri = Uri.parse('wss://breach-api-ws.qa.mvm-tech.xyz?token=$token');
      _channel = WebSocketChannel.connect(uri);
      
      _channel!.stream.listen(
        (data) {
          try {
            final jsonData = json.decode(data);
            final event = Event.fromJson(jsonData);
            onEventReceived(event);
          } catch (e) {
            onError('Failed to parse event: $e');
          }
        },
        onError: (error) {
          onError('WebSocket error: $error');
        },
        onDone: () {
          onError('WebSocket connection closed');
        },
      );
    } catch (e) {
      onError('Failed to connect to WebSocket: $e');
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  bool get isConnected => _channel != null;
}
