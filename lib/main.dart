import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'Firebase/firebase_config.dart';
import 'Firebase/notification_services.dart';
import 'app.dart';
import 'core/theme/theme_provider.dart';
import 'core/utils/hiveUtils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Future<void> initializeApp() async {
    await FirebaseConfig.initialize();
    await NotificationService.initialize();
    await _requestPermissions();
    await Hive.initFlutter();
    await HiveUtils.initHive();
  }

  initializeApp().then((_) {
    runApp(
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: MyApp(),
      ),
    );
  });
}

Future<void> _requestPermissions() async {
  await Permission.camera.request();
  await Permission.photos.request();
  final micStatus = await Permission.microphone.request();
  debugPrint("Microphone permission status: $micStatus");
}
