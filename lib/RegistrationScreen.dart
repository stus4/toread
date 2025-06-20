import 'package:flutter/material.dart';
import 'app_styles.dart'; // Імпортуємо стилі
import 'colors.dart'; // Імпортуємо кольори
import 'register_form.dart'; // Імпортуємо файл з валідацією
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dateController = TextEditingController();

  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      // Підготовка даних
      final Map<String, dynamic> data = {
        "username": _usernameController.text,
        "name": _firstNameController.text,
        "last_name": _lastNameController.text,
        "email": _emailController.text,
        "password": _passwordController.text,
        "birth": _dateController.text,
      };

      try {
        final response = await http.post(
          Uri.parse('$baseUrl/register'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Реєстрація успішна
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Реєстрація успішна!')),
          );
          Navigator.pop(context);
        } else {
          // Помилка з сервера
          final Map<String, dynamic> responseData =
              jsonDecode(utf8.decode(response.bodyBytes));
          final errorMessage = responseData['detail'] ?? 'Помилка реєстрації';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } catch (e) {
        // Помилка при підключенні або інша
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Помилка підключення: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Реєстрація'),
        backgroundColor: AppColors.anotherbrown,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _usernameController,
                  decoration: AppStyles.inputDecoration.copyWith(
                    labelText: 'Ім\'я користувача',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Будь ласка, введіть ім\'я користувача';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _firstNameController,
                  decoration: AppStyles.inputDecoration.copyWith(
                    labelText: 'Ім\'я',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Будь ласка, введіть ім\'я';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _lastNameController,
                  decoration: AppStyles.inputDecoration.copyWith(
                    labelText: 'Прізвище',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Будь ласка, введіть прізвище';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _emailController,
                  decoration: AppStyles.inputDecoration.copyWith(
                    labelText: 'Електронна пошта',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Будь ласка, введіть електронну пошту';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: AppStyles.inputDecoration.copyWith(
                    labelText: 'Пароль',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    String? error = FormValidation.validatePassword(value!);
                    return error;
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: AppStyles.inputDecoration.copyWith(
                    labelText: 'Підтвердження паролю',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Будь ласка, підтвердіть пароль';
                    }
                    if (value != _passwordController.text) {
                      return 'Паролі не співпадають';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _dateController,
                  decoration: AppStyles.inputDecoration.copyWith(
                    labelText: 'Дата народження',
                    prefixIcon: Icon(Icons.calendar_today),
                    hintText: 'Виберіть дату',
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  validator: (value) {
                    String? error = FormValidation.validateAge(_selectedDate);
                    return error;
                  },
                ),
                SizedBox(height: 30.0),
                ElevatedButton(
                  onPressed: _register,
                  style: AppStyles.elevatedButtonStyle,
                  child: Text('Зареєструватися'),
                ),
                SizedBox(height: 20.0),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Уже є акаунт? Увійти'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
