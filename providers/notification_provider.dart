import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  List<RemoteMessage> _notifications = [];
  int _unreadCount = 0;

  List<RemoteMessage> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  NotificationProvider() {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
    
    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _notifications.insert(0, message);
      _unreadCount++;
      notifyListeners();
    });

    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message);
    });

    // Check for initial message
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Handle notification tap based on data
    final data = message.data;
    print('Notification tapped: ${data}');
  }

  void markAsRead(int index) {
    if (index < _notifications.length) {
      _unreadCount = (_unreadCount - 1).clamp(0, _notifications.length);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    _unreadCount = 0;
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    _unreadCount = 0;
    notifyListeners();
  }
}