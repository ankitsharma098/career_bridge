import 'package:android/core/utils/utils.dart';
import 'package:android/features/Dashboard/bloc/employer_dashboard_bloc.dart';
import 'package:android/features/Dashboard/ui/employer_dashboard.dart';
import 'package:android/features/auth/bloc/auth_bloc.dart';
import 'package:android/features/auth/data/auth_api_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/ui/login.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  bool isLoggedIn = false;

  void checkLoginStatus() async {
    isLoggedIn = await HiveUtils.getLoggedIn();
    if (isLoggedIn) {
      print('User is logged in.');
    } else {
      print('User is not logged in.');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: isLoggedIn ? BlocProvider(
        create: (context) => EmployerDashboardBloc(),
        child: EmployerDashboardScreen(),
      ) :
      BlocProvider(
        create: (context) => LoginBloc(),
        child: LoginScreen(),
      ),
    );
  }
}
//
// class LoginScreen extends StatelessWidget {
//   final VoidCallback onToggleTheme;
//
//   const LoginScreen({Key? key, required this.onToggleTheme}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Login'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.brightness_6),
//             onPressed: onToggleTheme,
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Welcome Back!',
//               style: Theme.of(context).textTheme.displayLarge,
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               decoration: InputDecoration(
//                 labelText: 'Email',
//                 prefixIcon: const Icon(Icons.email),
//               ),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               decoration: InputDecoration(
//                 labelText: 'Password',
//                 prefixIcon: const Icon(Icons.lock),
//               ),
//               obscureText: true,
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 // Perform login action
//               },
//               child: const Text('Login'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
