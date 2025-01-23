import 'package:android/core/utils/utils.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveUtils.initHive();
  runApp(const MyApp());
}






