import 'package:flutter/material.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class FormValidation {
  // Перевірка пароля
  static String? validatePassword(String value) {
    if (value.isEmpty) {
      return 'Будь ласка, введіть пароль';
    }
    if (value.length < 6) {
      return 'Пароль має містити щонайменше 6 символів';
    }
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
      return 'Пароль повинен містити хоча б одну велику літеру';
    }
    if (!RegExp(r'(?=.*[0-9])').hasMatch(value)) {
      return 'Пароль повинен містити хоча б одну цифру';
    }
    return null;
  }

  // Перевірка віку користувача
  static String? validateAge(DateTime? birthDate) {
    if (birthDate == null) {
      return 'Будь ласка, виберіть дату народження';
    }

    final now = DateTime.now();
    final age = now.year - birthDate.year;

    // Перевіряємо, чи користувач досяг 13 років (мінімальний вік)
    if (age < 13 ||
        (age == 13 && now.month < birthDate.month) ||
        (age == 13 &&
            now.month == birthDate.month &&
            now.day < birthDate.day)) {
      return 'Вам має бути щонайменше 13 років для реєстрації';
    }

    return null;
  }
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false; // для основного пароля
  bool _isConfirmPasswordVisible = false; // для підтвердження пароля

  // Логіка для реєстрації
  void _register() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Реєстрація успішна!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Реєстрація'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Поле для введення паролю
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Будь ласка, введіть пароль';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              // Поле для підтвердження паролю
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Підтвердження паролю',
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
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
              SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: _register,
                child: Text('Зареєструватися'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
