import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event.dart';
import '../services/websocket_service.dart';

class EventsNotifier extends StateNotifier<List<Event>> {
  WebSocketService? _webSocketService;

  EventsNotifier() : super([]);

  void connect(String token) {
    _webSocketService = WebSocketService(
      onEventReceived: (event) {
        state = [event, ...state.take(4)]; // Keep only the 5 most recent events
      },
      onError: (error) {
        // Handle WebSocket errors
        print('WebSocket error: $error');
      },
    );
    _webSocketService!.connect();
  }

  void disconnect() {
    _webSocketService?.disconnect();
    _webSocketService = null;
  }

  void clearEvents() {
    state = [];
  }
}

final eventsProvider = StateNotifierProvider<EventsNotifier, List<Event>>((
  ref,
) {
  return EventsNotifier();
});
