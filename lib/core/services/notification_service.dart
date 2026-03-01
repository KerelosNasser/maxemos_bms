import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Request permission on initialization for newer Android versions
    _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(settings: initializationSettings);
  }

  static Future<void> showUploadProgress({
    required int id,
    required String title,
    required String body,
    required int progress,
    required int maxProgress,
  }) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'upload_progress_channel',
          'Upload Progress',
          channelDescription: 'Shows progress of book uploads to the archives',
          channelShowBadge: false,
          importance: Importance.max,
          priority: Priority.high,
          onlyAlertOnce: true,
          showProgress: true,
          maxProgress: maxProgress,
          progress: progress,
          // true means indeterminate (spins) if progress isn't known
          indeterminate: progress == 0 && maxProgress == 0,
        );
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
    );
  }

  static Future<void> showUploadComplete({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'upload_complete_channel',
          'Upload Notifications',
          channelDescription: 'Notifies when an upload is complete or failed',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
    );
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'general_notifications_channel',
          'General Notifications',
          channelDescription: 'General app notifications and alerts',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
    );
  }
}
