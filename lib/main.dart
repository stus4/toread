import 'package:flutter/material.dart';
import 'database_service.dart'; // імпортуємо новий файл
import 'welcome_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Перевірка БД',
      home: WelcomeScreen(),
    );
  }
}
