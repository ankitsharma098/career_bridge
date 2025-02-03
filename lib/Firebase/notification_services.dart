import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  
  
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  static Future initialize () async {
    const InitializationSettings initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings()
    );
    await _notificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onBackgroundMessage(_fireBaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {

      _showNotification(message);
    });
  }

  @pragma('vm:entry-point')
  static Future _fireBaseMessagingBackgroundHandler (RemoteMessage message)async{
      
     // await Firebase.initializeApp();
      _showNotification(message);
    }
    
  static Future _showNotification (RemoteMessage message) async {
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails( 'job_channel',
        'Job Notifications',
        importance: Importance.max,
        priority: Priority.high,)
    );
    
    await _notificationsPlugin.show(DateTime.now().microsecond, message.notification?.title ?? '', message.notification?.body ?? "", notificationDetails);
    
  }
   
  
  
}