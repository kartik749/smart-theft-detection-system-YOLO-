import 'package:flutter/material.dart';
import 'package:flutter_app/screen/alert_history.dart';
import 'package:flutter_app/screen/camera.dart';
import 'package:flutter_app/screen/home_screen.dart';
import 'package:flutter_app/screen/login.dart';
import 'package:flutter_app/screen/signup.dart';
import 'package:flutter_app/screen/splash.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => HomeScreen(),
        '/camera': (context) => CameraScreen(),
        '/alerts': (context) => AlertHistoryScreen(),
      },
    );
  }
}