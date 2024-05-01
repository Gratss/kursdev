import 'package:carcheck/screens/account_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:carcheck/screens/home_screen.dart';
import 'package:carcheck/screens/login_screen.dart';
import 'package:carcheck/screens/reset_password_screen.dart';
import 'package:carcheck/screens/signup_screen.dart';
import 'package:carcheck/screens/verify_email_screen.dart';
import 'package:carcheck/services/firebase_streem.dart';
import 'package:carcheck/screens/add_car_screen.dart';




Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        }),
      ),
      routes: {
        '/': (context) => const FirebaseStream(),
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/reset_password': (context) => const ResetPasswordScreen(),
        '/verify_email': (context) => const VerifyEmailScreen(),
        '/add_car_screen': (context) => const AddCarInfoScreen(),
        '/account_screen': (context) => const AccountScreen()
      },
      initialRoute: '/',
    );
  }
}
