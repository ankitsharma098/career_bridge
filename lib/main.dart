import 'package:android/Firebase/notification_services.dart';
import 'package:android/core/utils/hiveUtils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import 'Firebase/firebase_config.dart';
import 'app.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 // await Firebase.initializeApp();
  await FirebaseConfig.initialize();
  await NotificationService.initialize();

  await Hive.initFlutter();
  await HiveUtils.initHive();
  runApp(const MyApp());
}






