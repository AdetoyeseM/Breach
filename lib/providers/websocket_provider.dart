import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/websocket_service.dart'; 
import '../models/event.dart';

class WebSocketNotifier extends StateNotifier<WebSocketState> {
  WebSocketService? _webSocketService;
  Event? _lastProcessedEvent;
  
  WebSocketNotifier() : super(WebSocketState.initial());

  void connect() {
    if (state.isConnected) return; 
    // Use Future.microtask to avoid modifying provider during build
    Future.microtask(() {
      state = state.copyWith(isConnecting: true);
      
      _webSocketService = WebSocketService(
        onEventReceived: (event) { 
          // Check if this is a new event
          if (_lastProcessedEvent?.id != event.id) {
            _lastProcessedEvent = event;
            Future.microtask(() {
              state = state.copyWith(
                events: [event, ...state.events.take(9)], // Keep 10 most recent events
                lastEvent: event,
              );
            });
          }
        },
        onError: (error) { 
          Future.microtask(() {
            state = state.copyWith(
              error: error,
              isConnecting: false,
              isConnected: false,
            );
          });
        },
        onConnectionStatusChanged: (isConnected) { 
          Future.microtask(() {
            state = state.copyWith(
              isConnected: isConnected,
              isConnecting: false,
              error: isConnected ? null : state.error,
            );
          });
        },
      );
      
      try {
        _webSocketService!.connect();
      } catch (e) { 
        Future.microtask(() {
          state = state.copyWith(
            isConnecting: false,
            isConnected: false,
            error: e.toString(),
          );
        });
      }
    });
  }

  void disconnect() { 
    _webSocketService?.disconnect();
    _webSocketService = null;
    _lastProcessedEvent = null;
    Future.microtask(() {
      state = WebSocketState.initial();
    });
  }

  void clearEvents() {
    Future.microtask(() {
      state = state.copyWith(events: []);
    });
  }

  void clearError() {
    Future.microtask(() {
      state = state.copyWith(error: null);
    });
  }

  void clearLastEvent() {
    Future.microtask(() {
      state = state.copyWith(lastEvent: null);
    });
  }
}

class WebSocketState {
  final bool isConnected;
  final bool isConnecting;
  final String? error;
  final List<Event> events;
  final Event? lastEvent;

  WebSocketState({
    required this.isConnected,
    required this.isConnecting,
    this.error,
    required this.events,
    this.lastEvent,
  });

  factory WebSocketState.initial() {
    return WebSocketState(
      isConnected: false,
      isConnecting: false,
      events: [],
    );
  }

  WebSocketState copyWith({
    bool? isConnected,
    bool? isConnecting,
    String? error,
    List<Event>? events,
    Event? lastEvent,
  }) {
    return WebSocketState(
      isConnected: isConnected ?? this.isConnected,
      isConnecting: isConnecting ?? this.isConnecting,
      error: error,
      events: events ?? this.events,
      lastEvent: lastEvent ?? this.lastEvent,
    );
  }
}

final webSocketProvider = StateNotifierProvider<WebSocketNotifier, WebSocketState>((ref) {
  return WebSocketNotifier();
});
