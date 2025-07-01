import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(initSettings);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  Future<void> sendNotificationToAdmin({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get admin FCM token
      final adminQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: 'meathik@gmail.com')
          .limit(1)
          .get();

      if (adminQuery.docs.isNotEmpty) {
        final adminData = adminQuery.docs.first.data();
        final fcmToken = adminData['fcmToken'];
        
        if (fcmToken != null) {
          await sendNotification(
            token: fcmToken,
            title: title,
            body: body,
            data: data,
          );
        }
      }
    } catch (e) {
      print('Error sending notification to admin: $e');
    }
  }

  Future<void> sendNotification({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Store notification in Firestore for persistence
      await _firestore.collection('notifications').add({
        'token': token,
        'title': title,
        'body': body,
        'data': data ?? {},
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });

      // Send push notification via FCM
      // Note: In a real app, you would use Firebase Functions or a server
      // to send the actual push notification using the FCM Admin SDK
      print('Notification sent: $title - $body');
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'jkplus_channel',
      'JK Plus Notifications',
      channelDescription: 'Notifications for JK Plus app',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(id, title, body, details, payload: payload);
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}