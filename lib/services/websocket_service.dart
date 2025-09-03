import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/event.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  final Function(Event) onEventReceived;
  final Function(String) onError;
  final Function(bool)? onConnectionStatusChanged;
  bool _isConnecting = false;

  WebSocketService({
    required this.onEventReceived,
    required this.onError,
    this.onConnectionStatusChanged,
  });

  void connect() {
    if (_isConnecting) return;
    _isConnecting = true;

    try {
      final uri = Uri.parse('wss://breach-api-ws.qa.mvm-tech.xyz');
      _channel = WebSocketChannel.connect(uri);

      _channel!.stream.listen(
        (data) {
          try { 
            if (data == 'pong') {
              return;
            }

            final jsonData = json.decode(data);
            final event = Event.fromJson(jsonData);
            onEventReceived(event);
          } catch (e) { 
            //
          }
        },
        onError: (error) {
          _isConnecting = false;
          onError('WebSocket error: $error');
          _stopPingTimer();
          onConnectionStatusChanged?.call(false);
          _scheduleReconnect();
        },
        onDone: () {
          _isConnecting = false;
          onError('WebSocket connection closed');
          _stopPingTimer();
          onConnectionStatusChanged?.call(false);
          _scheduleReconnect();
        },
      );

      // Start ping timer
      _startPingTimer();
      _isConnecting = false;
      onConnectionStatusChanged?.call(true);
    } catch (e) {
      _isConnecting = false;
      onError('Failed to connect to WebSocket: $e');
      _scheduleReconnect();
    }
  }

  void disconnect() {
    _stopPingTimer();
    _stopReconnectTimer();
    if (_channel != null) {
      try {
        _channel!.sink.close();
      } catch (e) {
        //
      }
      _channel = null;
    }
    _isConnecting = false;
    onConnectionStatusChanged?.call(false);
  }

  void _startPingTimer() {
    _stopPingTimer(); // Stop any existing timer
    _pingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_channel != null && _channel!.sink != null) {
        try {
          _channel!.sink.add('ping');
        } catch (e) {
          _stopPingTimer();
          onConnectionStatusChanged?.call(false);
        }
      } else {
        _stopPingTimer();
      }
    });
  }

  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  void _scheduleReconnect() {
    _stopReconnectTimer();
    _reconnectTimer = Timer(const Duration(seconds: 10), () {
      connect();
    });
  }

  void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  bool get isConnected => _channel != null && !_isConnecting;
}
