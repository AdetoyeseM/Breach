import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'websocket_provider.dart';

class WebSocketInitNotifier extends StateNotifier<bool> {
  final WebSocketNotifier _webSocketNotifier;
  
  WebSocketInitNotifier(this._webSocketNotifier) : super(false);

  void initialize() { 
    if (!state) { 
      _webSocketNotifier.connect();
      state = true;
    }
  }

  void cleanup() {
    if (state) {
      _webSocketNotifier.disconnect();
      state = false;
    }
  }
}

final webSocketInitProvider = StateNotifierProvider<WebSocketInitNotifier, bool>((ref) {
  final webSocketNotifier = ref.watch(webSocketProvider.notifier);
  return WebSocketInitNotifier(webSocketNotifier);
});
