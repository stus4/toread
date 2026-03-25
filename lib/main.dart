import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/home/welcome_screen.dart';
import 'features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('user_id');

  runApp(MyApp(userId: userId));
}

class MyApp extends StatelessWidget {
  final String? userId;

  const MyApp({required this.userId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2read',
      theme: ThemeData(
        fontFamily: 'Roboto',
      ),
      home: userId != null ? HomeScreen(userId: userId!) : WelcomeScreen(),
    );
  }
}
