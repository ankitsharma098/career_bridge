import 'package:android/Firebase/notification_services.dart';
import 'package:android/core/utils/hiveUtils.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'Firebase/firebase_config.dart';
import 'app.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  await FirebaseConfig.initialize();
  await NotificationService.initialize();
  await Permission.camera.request();
  await Permission.photos.request();
  await Hive.initFlutter();
  await HiveUtils.initHive();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}
