import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static String? _fcmToken;

  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Notification tapped: ${response.payload}');
      },
    );

    await _createNotificationChannel();

    NotificationSettings permissionSettings = await _messaging
        .requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );

    if (permissionSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      print('✅ Notification permissions granted');
    } else {
      print('❌ Notification permissions denied');
    }

    _fcmToken = await _messaging.getToken();
    print('🔑 FCM Token: $_fcmToken');

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Foreground message received: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('👆 Notification tapped: ${message.notification?.title}');
    });

    _messaging.onTokenRefresh.listen((String token) {
      print('🔄 FCM Token refreshed: $token');
      _fcmToken = token;
    });
  }

  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'todo_reminders',
      'Todo Reminders',
      description: 'Notifications for todo reminders 1 hour before deadline',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  static Future<void> scheduleNotification(
    int todoId,
    String todoTitle,
    DateTime notificationTime,
  ) async {
    if (_fcmToken == null) {
      print('❌ FCM Token not available');
      return;
    }

    if (notificationTime.isBefore(DateTime.now())) {
      print('❌ Cannot schedule notification for past time: $notificationTime');
      return;
    }

    print('📅 Scheduling push notification for: $notificationTime');
    print('📱 Current time: ${DateTime.now()}');
    print(
      '⏳ Time until notification: ${notificationTime.difference(DateTime.now())}',
    );

    try {
      final delayDuration = notificationTime.difference(DateTime.now());

      if (delayDuration.inSeconds > 0) {
        _scheduleDelayedNotification(todoId, todoTitle, delayDuration);

        print('✅ Notification scheduled successfully for todo: $todoTitle');
        print('⏰ Will trigger in: ${delayDuration.toString()}');
      }
    } catch (e) {
      print('❌ Error scheduling notification: $e');
    }
  }

  static void _scheduleDelayedNotification(
    int todoId,
    String todoTitle,
    Duration delay,
  ) {
    Future.delayed(delay, () async {
      await _showImmediateNotification(todoId, todoTitle);
    });
  }

  static Future<void> _showImmediateNotification(
    int todoId,
    String todoTitle,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'todo_reminders',
          'Todo Reminders',
          channelDescription:
              'Notifications for todo reminders 1 hour before deadline',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(''),
          ticker: 'TaskRoom Reminder',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      badgeNumber: 1,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      todoId,
      '⏰ TaskRoom Reminder',
      '📝 "$todoTitle" is due in 1 hour!',
      details,
      payload: 'todo_reminder_$todoId',
    );

    print('🔔 Push notification shown for: $todoTitle');
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    print('🗑️ Cancelled notification for todo ID: $id');
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('🗑️ Cancelled all notifications');
  }

  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'todo_reminders',
          'Todo Reminders',
          channelDescription: 'Notifications for todo reminders',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      message.hashCode,
      message.notification?.title ?? 'TaskRoom',
      message.notification?.body ?? 'You have a notification',
      details,
      payload: message.data.toString(),
    );
  }

  static String? get fcmToken => _fcmToken;

  static Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'todo_reminders',
          'Todo Reminders',
          channelDescription: 'Test notification',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      999,
      '🧪 Test Notification',
      'This is a test notification from TaskRoom',
      details,
    );

    print('🧪 Test notification shown');
  }

  static Future<void> testImmediateReminder(String todoTitle) async {
    await _showImmediateNotification(999, todoTitle);
  }

  static Future<void> scheduleWithBackend(
    int todoId,
    String todoTitle,
    DateTime notificationTime,
  ) async {
    if (_fcmToken == null) return;
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('🔔 Handling a background message: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
}
