import 'package:flutter/material.dart';
import '../models/event.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  void showEventNotification(BuildContext context, Event event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(_getEventIcon(event.type), color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  if (event.description.isNotEmpty)
                    Text(
                      event.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: _getEventColor(event.type),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void showConnectionStatus(
    BuildContext context,
    bool isConnected,
    String? error,
  ) {
    if (error != null) {
  
    } else if (isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              const Text(
                'Connected to live updates',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  IconData _getEventIcon(String type) {
    switch (type.toLowerCase()) {
      case 'post':
        return Icons.article;
      case 'comment':
        return Icons.comment;
      case 'like':
        return Icons.favorite;
      case 'follow':
        return Icons.person_add;
      case 'notification':
        return Icons.notifications;
      default:
        return Icons.info;
    }
  }

  Color _getEventColor(String type) {
    switch (type.toLowerCase()) {
      case 'post':
        return Colors.blue;
      case 'comment':
        return Colors.green;
      case 'like':
        return Colors.red;
      case 'follow':
        return Colors.purple;
      case 'notification':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
