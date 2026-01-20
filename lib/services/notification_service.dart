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
  static const String _lastDuaaDeliveryKey = 'last_duaa_delivery_date';
  static const String _lastMorningAzkarDeliveryKey =
      'last_morning_azkar_delivery_date';
  static const String _lastEveningAzkarDeliveryKey =
      'last_evening_azkar_delivery_date';

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
    await scheduleMorningAzkarNotification(); // 9 AM
    await scheduleEveningAzkarNotification(); // 7 PM

    // Check if any notifications should have been delivered today
    await _checkAndSaveOverdueNotifications();

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
  void _onNotificationTapped(NotificationResponse response) async {
    if (kDebugMode) {
      print('🔔 Notification tapped: ${response.payload}');
    }

    // Parse payload and save to history (only once per day)
    if (response.payload != null) {
      try {
        final payload = json.decode(response.payload!);
        final type = payload['type'] as String?;
        final content = payload['content'] as String?;
        final screen = payload['screen'] as String?;

        if (kDebugMode) {
          print('📍 Navigation requested to: $screen');
          print('📝 Notification type: $type');
        }

        // Save to history only if not already saved today
        if (type != null && content != null) {
          await _saveNotificationIfNotToday(type, content);
        }

        // TODO: Implement navigation using GlobalKey<NavigatorState>
        // For now, the payload is parsed and ready
        // Payload contains:
        // - 'screen': 'azkar' or 'notifications'
        // - 'type': 'morning_azkar', 'evening_azkar', 'duaa'
        // - 'category': Category name for azkar
        // - 'content': The actual text
      } catch (e) {
        if (kDebugMode) {
          print('❌ Error parsing notification payload: $e');
        }
      }
    }
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

      // final scheduledDate = now.add(const Duration(minutes: 2));
      // // Schedule for 3 PM daily

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        13, // 3 PM
        0,
      );

      // If 3 PM already passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

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

      // DO NOT save to history here - will be saved when notification is delivered

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

  // Schedule morning Azkar notification at 9 AM
  Future<void> scheduleMorningAzkarNotification() async {
    try {
      if (kDebugMode) {
        print('🌅 Scheduling morning Azkar notification at 9 AM...');
      }

      // Cancel previous notification
      await _notificationsPlugin.cancel(morningAzkarId);

      // Load random morning azkar
      final azkar = await _getRandomAzkar('أذكار الصباح');

      if (azkar == null || azkar.isEmpty) {
        if (kDebugMode) {
          print('⚠️ No morning azkar found to schedule');
        }
        return;
      }

      // Schedule for 9 AM daily
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        9, // 9 AM
        0,
      );

      // If 9 AM already passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notificationsPlugin.zonedSchedule(
        morningAzkarId,
        '🌅 أذكار الصباح',
        azkar,
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'morning_azkar',
            'أذكار الصباح',
            channelDescription: 'إشعار يومي بأذكار الصباح',
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(
              azkar,
              contentTitle: '🌅 أذكار الصباح',
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
          'type': 'morning_azkar',
          'screen': 'azkar',
          'category': 'أذكار الصباح',
          'content': azkar,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      // DO NOT save to history here - will be saved when notification is delivered

      if (kDebugMode) {
        print(
            '✅ Morning Azkar notification scheduled for ${scheduledDate.hour}:${scheduledDate.minute}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error scheduling morning Azkar notification: $e');
      }
    }
  }

  // Schedule evening Azkar notification at 7 PM
  Future<void> scheduleEveningAzkarNotification() async {
    try {
      if (kDebugMode) {
        print('🌙 Scheduling evening Azkar notification at 7 PM...');
      }

      // Cancel previous notification
      await _notificationsPlugin.cancel(eveningAzkarId);

      // Load random evening azkar
      final azkar = await _getRandomAzkar('أذكار المساء');

      if (azkar == null || azkar.isEmpty) {
        if (kDebugMode) {
          print('⚠️ No evening azkar found to schedule');
        }
        return;
      }

      // Schedule for 7 PM daily
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        19, // 7 PM (19:00)
        0,
      );

      // If 7 PM already passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notificationsPlugin.zonedSchedule(
        eveningAzkarId,
        '🌙 أذكار المساء',
        azkar,
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'evening_azkar',
            'أذكار المساء',
            channelDescription: 'إشعار يومي بأذكار المساء',
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(
              azkar,
              contentTitle: '🌙 أذكار المساء',
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
          'type': 'evening_azkar',
          'screen': 'azkar',
          'category': 'أذكار المساء',
          'content': azkar,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      // DO NOT save to history here - will be saved when notification is delivered

      if (kDebugMode) {
        print(
            '✅ Evening Azkar notification scheduled for ${scheduledDate.hour}:${scheduledDate.minute}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error scheduling evening Azkar notification: $e');
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

  // Get random Azkar from JSON by category
  Future<String?> _getRandomAzkar(String category) async {
    try {
      // Load azkar.json
      final jsonString = await rootBundle.loadString('assets/data/azkar.json');
      final Map<String, dynamic> decoded = json.decode(jsonString);

      // Get the specific category (morning or evening)
      final categoryData = decoded[category];

      if (categoryData == null) {
        if (kDebugMode) {
          print('⚠️ Category "$category" not found in azkar.json');
        }
        return null;
      }

      List<String> azkarList = [];

      // Parse the azkar data structure
      if (categoryData is List) {
        for (var item in categoryData) {
          if (item is List) {
            // Nested array structure
            for (var subItem in item) {
              if (subItem is Map && subItem['zikr'] != null) {
                azkarList.add(subItem['zikr'].toString());
              }
            }
          } else if (item is Map && item['zikr'] != null) {
            // Direct map structure
            azkarList.add(item['zikr'].toString());
          }
        }
      }

      if (azkarList.isEmpty) {
        if (kDebugMode) {
          print('⚠️ No azkar found in category "$category"');
        }
        return 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ';
      }

      // Select random azkar
      final random = Random();
      final selectedAzkar = azkarList[random.nextInt(azkarList.length)];

      return selectedAzkar;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading azkar: $e');
      }
      return null;
    }
  }

  // Check and save notifications that should have been delivered today
  Future<void> _checkAndSaveOverdueNotifications() async {
    try {
      final now = DateTime.now();
      final currentHour = now.hour;

      if (kDebugMode) {
        print(
            '🔍 Checking for overdue notifications... Current time: ${now.hour}:${now.minute}');
      }

      // Check morning azkar (9 AM)
      if (currentHour >= 9) {
        final azkar = await _getRandomAzkar('أذكار الصباح');
        if (azkar != null && azkar.isNotEmpty) {
          await _saveNotificationIfNotToday('morning_azkar', azkar);
        }
      }

      // Check duaa (1 PM / 13:00)
      if (currentHour >= 13) {
        final duaa = await _getRandomDuaa();
        if (duaa != null && duaa.isNotEmpty) {
          await _saveNotificationIfNotToday('duaa', duaa);
        }
      }

      // Check evening azkar (7 PM / 19:00)
      if (currentHour >= 19) {
        final azkar = await _getRandomAzkar('أذكار المساء');
        if (azkar != null && azkar.isNotEmpty) {
          await _saveNotificationIfNotToday('evening_azkar', azkar);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking overdue notifications: $e');
      }
    }
  }

  // Save notification to history only if not already saved today
  Future<void> _saveNotificationIfNotToday(String type, String content) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today =
          DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD

      // Determine the key and title based on type
      String deliveryKey;
      String title;

      switch (type) {
        case 'duaa':
          deliveryKey = _lastDuaaDeliveryKey;
          title = 'دعاء اليوم';
          break;
        case 'morning_azkar':
          deliveryKey = _lastMorningAzkarDeliveryKey;
          title = 'أذكار الصباح';
          break;
        case 'evening_azkar':
          deliveryKey = _lastEveningAzkarDeliveryKey;
          title = 'أذكار المساء';
          break;
        default:
          if (kDebugMode) {
            print('⚠️ Unknown notification type: $type');
          }
          return;
      }

      // Check if already saved today
      final lastDeliveryDate = prefs.getString(deliveryKey);
      if (lastDeliveryDate == today) {
        if (kDebugMode) {
          print('ℹ️ Notification "$type" already saved today, skipping...');
        }
        return;
      }

      // Save to history
      await _saveNotification(title, content, type);

      // Update last delivery date
      await prefs.setString(deliveryKey, today);

      if (kDebugMode) {
        print('✅ Notification "$type" saved to history for date: $today');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in _saveNotificationIfNotToday: $e');
      }
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
