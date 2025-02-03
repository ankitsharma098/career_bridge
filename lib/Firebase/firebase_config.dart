import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../firebase_options.dart';

class FirebaseConfig {


  static Future initialize () async {

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await FirebaseMessaging.instance.requestPermission( alert: true,
      badge: true,
      sound: true,);

    String? token = await FirebaseMessaging.instance.getToken();
   //Api caliing await sendtokenTosercer();
    print("token $token");
  }


}