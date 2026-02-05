import 'package:flutter/material.dart';
import 'colors.dart'; // Імпортуйте ваші кольори

class AppStyles {
  // Стиль для полів вводу
  static InputDecoration inputDecoration = InputDecoration(
    labelStyle: TextStyle(color: Colors.black), // Колір тексту лейбла
    prefixIconColor: Colors.black, // Колір іконки префікса
    border: OutlineInputBorder(
      borderSide: BorderSide(
        color: AppColors.borderColor, // Стандартний колір бордера
        width: 2.0,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: AppColors.secondaryColor, // Колір бордера при фокусі
        width: 2.0,
      ),
    ),
  );

  // Стиль для заголовків
  static TextStyle titleTextStyle = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  // Стиль для основного тексту
  static TextStyle bodyTextStyle = TextStyle(
    fontSize: 16.0,
    color: Colors.black54,
  );

  // Стиль для кнопок
  static ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.secondaryColor, // Колір фону
    foregroundColor: Colors.white, // Колір тексту на кнопці
    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
    textStyle: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
  );
}
