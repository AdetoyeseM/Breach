import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/websocket_provider.dart';
import '../services/notification_service.dart';

class WebSocketNotificationListener extends ConsumerStatefulWidget {
  final Widget child;

  const WebSocketNotificationListener({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<WebSocketNotificationListener> createState() => _WebSocketNotificationListenerState();
}

class _WebSocketNotificationListenerState extends ConsumerState<WebSocketNotificationListener> {
  final NotificationService _notificationService = NotificationService();
  String? _lastError;
  bool _hasShownConnectionSuccess = false;

  @override
  Widget build(BuildContext context) {
    final webSocketState = ref.watch(webSocketProvider);
    
    // Handle connection status notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleConnectionStatus(webSocketState);
      _handleNewEvents(webSocketState);
    });

    return widget.child;
  }

  void _handleConnectionStatus(dynamic webSocketState) {
    // Handle error notifications
    if (webSocketState.error != null && webSocketState.error != _lastError) {
      _lastError = webSocketState.error;
      _notificationService.showConnectionStatus(
        context,
        false,
        webSocketState.error,
      );
    } else if (webSocketState.error == null) {
      _lastError = null;
    }

    // Handle successful connection notification (only show once)
    if (webSocketState.isConnected && !_hasShownConnectionSuccess) {
      _hasShownConnectionSuccess = true;
      _notificationService.showConnectionStatus(
        context,
        true,
        null,
      );
    } else if (!webSocketState.isConnected) {
      _hasShownConnectionSuccess = false;
    }
  }

  void _handleNewEvents(dynamic webSocketState) {
    // Handle new event notifications
    if (webSocketState.lastEvent != null) {
      _notificationService.showEventNotification(
        context,
        webSocketState.lastEvent!,
      );
      
      // Clear the last event to prevent duplicate notifications
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          ref.read(webSocketProvider.notifier).clearLastEvent();
        }
      });
    }
  }
}
