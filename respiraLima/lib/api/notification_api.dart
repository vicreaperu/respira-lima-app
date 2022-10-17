
import 'package:app4/screens/map_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationApi {
  static final _localNotificationService = FlutterLocalNotificationsPlugin();
  Future initialize() async {
      final AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const IOSInitializationSettings iosInitializationSettings = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification
    );
    final  InitializationSettings settings =  InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings
    );

    await _localNotificationService.initialize(
      settings,
      onSelectNotification: onSelectNotification,
    );
  }
  Future<NotificationDetails> _notificationDetails(bool ongoin, bool indeterminate, bool autoCancel) async {
    AndroidNotificationDetails androidNotificationDetails =  AndroidNotificationDetails(
      'channel_id', 
      'channel_name',
      channelDescription: 'description',
      priority:  Priority.max,
      playSound: true,
      autoCancel: autoCancel,
      indeterminate: indeterminate,
      ongoing: ongoin,
      );
    const IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();
    return  NotificationDetails(android: androidNotificationDetails, iOS: iosNotificationDetails);
  }
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    bool? ongoin,
    bool? indeterminate,
    bool? autoCancel,
  }) async {
    final details = await _notificationDetails(ongoin ?? true, indeterminate ?? true, autoCancel ?? false);
    await _localNotificationService.show(id, title, body, details);
  }

  Future<void> closeNotification() async {
    await _localNotificationService.cancelAll();
  }
  static void onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) {
    print('id $id');
  }

  static void onSelectNotification(String? payload) {
    print('paylod $payload');
  }
}



// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationApi {
//   static final _notifications = FlutterLocalNotificationsPlugin();
//   static Future initialize() async {
    
//     return const NotificationDetails(
//       android: AndroidNotificationDetails(
//         'channel id', 
//         'channel name', 
//         channelDescription: 'channel description',
//         importance: Importance.max,
//         ),
//       iOS: IOSNotificationDetails()
//     );
//   }
//   static Future showNotification({
//     int id = 0,
//     String? title,
//     String? body,
//     String? payload,
//   }) async {
//     await _notifications.show(id, title, body, await initialize(), payload: payload);
//   }
// }