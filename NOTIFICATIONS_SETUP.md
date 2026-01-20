# 🔔 تعليمات إعداد نظام الإشعارات

## 📦 الخطوة 1: إضافة Packages المطلوبة

### في `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Existing packages...
  
  # ✅ Add these notification packages:
  flutter_local_notifications: ^17.0.0
  timezone: ^0.9.2
```

### تثبيت الـ Packages:

```bash
flutter pub get
```

---

## 🤖 الخطوة 2: إعداد Android

### في `android/app/src/main/AndroidManifest.xml`:

أضف هذه الـ permissions **داخل** `<manifest>`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- ✅ Add these permissions -->
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    
    <application ...>
        <!-- ✅ Add this receiver inside <application> -->
        <receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver"
            android:exported="false">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
            </intent-filter>
        </receiver>
        
        <receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"
            android:exported="false"/>
        
        <!-- Rest of your app config -->
    </application>
</manifest>
```

---

## 🍎 الخطوة 3: إعداد iOS (Optional)

### في `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // ✅ Add notification authorization
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

---

## ✅ الخطوة 4: التأكد من الملفات

تأكد من وجود هذه الملفات:

```
✅ lib/services/notification_service.dart
✅ lib/screens/notifications/notifications_screen.dart
✅ assets/data/duaa_elyoum.json
✅ lib/main.dart (updated)
✅ lib/screens/home/home_screen.dart (updated)
```

---

## 🚀 الخطوة 5: تشغيل التطبيق

```bash
flutter clean
flutter pub get
flutter run
```

---

## 🔍 اختبار النظام

### 1. إشعار تجريبي فوري:

- اضغط على أيقونة الإشعارات في الـ BottomNavBar
- اضغط على أيقونة "🔔" في AppBar
- سيظهر إشعار فوري للتجربة

### 2. إشعار يومي (3 PM):

في **Debug Mode**:
- الإشعار سيظهر بعد **10 ثوانٍ** من فتح التطبيق (للتجربة)

في **Production Mode**:
- الإشعار سيظهر يومياً الساعة **3 PM**

### 3. عرض الإشعارات المحفوظة:

- اضغط على تبويب "الإشعارات"
- سترى قائمة بكل الإشعارات السابقة
- الإشعارات غير المقروءة تظهر بنقطة خضراء

---

## ⚙️ التخصيص

### تغيير وقت الإشعار اليومي:

في `notification_service.dart` سطر 134:

```dart
var scheduledDate = tz.TZDateTime(
  tz.local,
  now.year,
  now.month,
  now.day,
  15, // ✅ غيّر هذا الرقم (15 = 3 PM)
  0,
);
```

### إضافة إشعارات أذكار الصباح/المساء:

```dart
// في NotificationService
Future<void> scheduleMorningAzkar() async {
  // Schedule for 6 AM
  var scheduledDate = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    6, // 6 AM
    0,
  );
  
  await _notificationsPlugin.zonedSchedule(
    morningAzkarId,
    '🌅 أذكار الصباح',
    'حان وقت أذكار الصباح',
    scheduledDate,
    // ... notification details
    matchDateTimeComponents: DateTimeComponents.time,
  );
}
```

---

## 🎨 ميزات النظام

✅ إشعار يومي الساعة 3 PM بدعاء عشوائي
✅ قراءة الأدعية من `duaa_elyoum.json`
✅ تصميم card جميل للإشعارات
✅ حفظ الإشعارات في الذاكرة المحلية
✅ شاشة عرض الإشعارات مع التاريخ
✅ تمييز الإشعارات المقروءة/غير المقروءة
✅ إمكانية حذف جميع الإشعارات
✅ دعم RTL للنصوص العربية
✅ يعمل في Background و Terminated
✅ Test notification للتجربة السريعة

---

## 🐛 Debug Mode vs Production

### Debug Mode:
- الإشعار يظهر بعد **10 ثوانٍ**
- رسائل تفصيلية في Console
- `if (kDebugMode)` يجعل التجربة أسهل

### Production Mode:
- الإشعار يظهر في الوقت المحدد (3 PM)
- لا رسائل debug
- أداء محسّن

### تعطيل Debug Mode للتجربة الحقيقية:

في `notification_service.dart` سطر 147، **احذف** هذا الكود:

```dart
// For DEBUG: Schedule in 10 seconds instead of 3 PM
if (kDebugMode) {
  scheduledDate = now.add(const Duration(seconds: 10));
  print('🐛 DEBUG MODE: Scheduling in 10 seconds instead of 3 PM');
}
```

---

## 📱 Console Output المتوقع

```
🔔 Initializing NotificationService...
📅 Scheduling daily Duaa notification at 3 PM...
📖 Loading duaa_elyoum.json...
🐛 DEBUG MODE: Scheduling in 10 seconds instead of 3 PM
✅ Duaa notification scheduled for 15:0
💾 Notification saved to history
✅ NotificationService initialized successfully
```

بعد 10 ثوانٍ:
```
🔔 Notification tapped: {"type":"duaa","screen":"notifications",...}
```

---

## ❓ Troubleshooting

### المشكلة: الإشعار لا يظهر

**الحل:**
1. تأكد من الـ Permissions في AndroidManifest.xml
2. تأكد من تثبيت الـ packages (`flutter pub get`)
3. اعمل `flutter clean` ثم `flutter run`
4. على Android 13+، اطلب permission الإشعارات من الإعدادات

### المشكلة: الإشعار يظهر لكن لا navigation

**الحل:**
- الـ payload يُحفظ في الإشعار
- يمكن استخدامه للـ navigation عند الضغط
- سيتم تطبيق ذلك في المرحلة التالية

### المشكلة: ملف duaa_elyoum.json غير موجود

**الحل:**
```bash
# تأكد من وجود الملف
ls assets/data/duaa_elyoum.json

# تأكد من إضافته في pubspec.yaml
assets:
  - assets/data/
```

---

## 🎯 Next Steps

1. ✅ تشغيل التطبيق واختبار الإشعار التجريبي
2. ✅ انتظار 10 ثوانٍ لرؤية الإشعار اليومي (Debug Mode)
3. ✅ فتح شاشة الإشعارات ورؤية السجل
4. ⏭️ إضافة navigation عند الضغط على الإشعار (Optional)
5. ⏭️ إضافة إشعارات أذكار الصباح/المساء

---

تم! 🎉 نظام الإشعارات جاهز للاستخدام!
