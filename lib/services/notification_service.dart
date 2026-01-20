import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final Random _random = Random();

  // Keys for SharedPreferences
  static const String _notificationsKey = 'saved_notifications';
  static const String _lastDuaaKey = 'last_duaa_notification';

  // Notification IDs
  static const int duaaNotificationId = 100;
  static const int morningAzkarId = 101;
  static const int eveningAzkarId = 102;

  // Initialize notification service
  Future<void> init() async {
    if (kDebugMode) {
      print('🔔 Initializing NotificationService...');
    }

    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Cairo')); // Egypt timezone

    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize plugin
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();

    // Schedule daily notifications
    await scheduleDailyDuaaNotification();

    if (kDebugMode) {
      print('✅ NotificationService initialized successfully');
    }
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      print('🔔 Notification tapped: ${response.payload}');
    }

    // The payload will be handled by the app navigation
    // We'll implement this in main.dart
  }

  // Schedule daily Duaa notification at 3 PM
  Future<void> scheduleDailyDuaaNotification() async {
    try {
      if (kDebugMode) {
        print('📅 Scheduling daily Duaa notification at 3 PM...');
      }

      // Cancel previous notification
      await _notificationsPlugin.cancel(duaaNotificationId);

      // Load random duaa
      final duaa = await _getRandomDuaa();

      if (duaa == null || duaa.isEmpty) {
        if (kDebugMode) {
          print('⚠️ No duaa found to schedule');
        }
        return;
      }

      // // Schedule for 3 PM daily
      final now = tz.TZDateTime.now(tz.local);
      final scheduledDate = now.add(const Duration(minutes: 2));

      // var scheduledDate = tz.TZDateTime(
      //   tz.local,
      //   now.year,
      //   now.month,
      //   now.day,
      //   15, // 3 PM
      //   0,
      // );

      // // If 3 PM already passed today, schedule for tomorrow
      // if (scheduledDate.isBefore(now)) {
      //   scheduledDate = scheduledDate.add(const Duration(days: 1));
      // }

      await _notificationsPlugin.zonedSchedule(
        duaaNotificationId,
        '🤲 دعاء اليوم',
        duaa,
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_duaa',
            'دعاء يومي',
            channelDescription: 'إشعار يومي بدعاء من القرآن',
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(
              duaa,
              contentTitle: '🤲 دعاء اليوم',
              summaryText: 'أذكاري',
            ),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: json.encode({
          'type': 'duaa',
          'screen': 'notifications',
          'content': duaa,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      // Save to notification history
      await _saveNotification('دعاء اليوم', duaa, 'duaa');

      if (kDebugMode) {
        print(
            '✅ Duaa notification scheduled for ${scheduledDate.hour}:${scheduledDate.minute}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error scheduling Duaa notification: $e');
      }
    }
  }

  // Get random Duaa from JSON
  Future<String?> _getRandomDuaa() async {
    try {
      // Load duaa_elyoum.json
      final jsonString =
          await rootBundle.loadString('assets/data/duaa_elyoum.json');
      final decoded = json.decode(jsonString);

      List<String> duas = [];

      if (decoded is Map && decoded['duas'] != null) {
        // Structure: { "duas": ["dua1", "dua2", ...] }
        final duasData = decoded['duas'];
        if (duasData is List) {
          duas = duasData.map((d) => d.toString()).toList();
        }
      } else if (decoded is List) {
        // Structure: ["dua1", "dua2", ...]
        duas = decoded.map((d) => d.toString()).toList();
      }

      if (duas.isEmpty) {
        return null;
      }

      // Get random duaa (different from last one if possible)
      String selectedDuaa;
      if (duas.length > 1) {
        final prefs = await SharedPreferences.getInstance();
        final lastDuaa = prefs.getString(_lastDuaaKey);

        // Try to find different duaa
        int attempts = 0;
        do {
          selectedDuaa = duas[_random.nextInt(duas.length)];
          attempts++;
        } while (selectedDuaa == lastDuaa && attempts < 10);

        // Save as last duaa
        await prefs.setString(_lastDuaaKey, selectedDuaa);
      } else {
        selectedDuaa = duas[0];
      }

      return selectedDuaa;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading duaa: $e');
      }
      return null;
    }
  }

  // Save notification to history
  Future<void> _saveNotification(
      String title, String content, String type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);

      List<Map<String, dynamic>> notifications = [];
      if (notificationsJson != null) {
        final decoded = json.decode(notificationsJson);
        notifications = List<Map<String, dynamic>>.from(decoded);
      }

      // Add new notification
      notifications.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': title,
        'content': content,
        'type': type,
        'timestamp': DateTime.now().toIso8601String(),
        'read': false,
      });

      // Keep only last 50 notifications
      if (notifications.length > 50) {
        notifications = notifications.sublist(0, 50);
      }

      // Save back
      await prefs.setString(_notificationsKey, json.encode(notifications));

      if (kDebugMode) {
        print('💾 Notification saved to history');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving notification: $e');
      }
    }
  }

  // Get all saved notifications
  Future<List<Map<String, dynamic>>> getSavedNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);

      if (notificationsJson == null) {
        return [];
      }

      final decoded = json.decode(notificationsJson);
      return List<Map<String, dynamic>>.from(decoded);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading notifications: $e');
      }
      return [];
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);

      if (notificationsJson == null) return;

      final decoded = json.decode(notificationsJson);
      List<Map<String, dynamic>> notifications =
          List<Map<String, dynamic>>.from(decoded);

      // Find and mark as read
      for (var notification in notifications) {
        if (notification['id'] == notificationId) {
          notification['read'] = true;
          break;
        }
      }

      // Save back
      await prefs.setString(_notificationsKey, json.encode(notifications));
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error marking notification as read: $e');
      }
    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_notificationsKey);

      if (kDebugMode) {
        print('🗑️ All notifications cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing notifications: $e');
      }
    }
  }

  // Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
