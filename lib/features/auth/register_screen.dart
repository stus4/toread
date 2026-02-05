import 'package:flutter/material.dart';
import '../../core/styles/app_styles.dart'; // Імпортуємо стилі
import '../../core/styles/colors.dart'; // Імпортуємо кольори
import 'register_form.dart'; // Імпортуємо файл з валідацією
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F1EB), // Світло-бежевий
              Color(0xFFE8DDD4), // Темніший бежевий
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  SizedBox(height: 20),

                  // Заголовок з кнопкою назад
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            color: Color(0xFF8B6F47),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'Реєстрація',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4E37),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 30),

                  // Іконка реєстрації
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFF8B6F47),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.person_add,
                      size: 40,
                      color: Color(0xFFF5F1EB),
                    ),
                  ),

                  SizedBox(height: 20),

                  Text(
                    'Створіть новий акаунт',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF8B6F47),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: 30),

                  // Форма в контейнері
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Ім'я користувача
                          _buildInputField(
                            controller: _usernameController,
                            label: 'Ім\'я користувача',
                            icon: Icons.account_circle_outlined,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Будь ласка, введіть ім\'я користувача';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 20),

                          // Ім'я та прізвище в одному рядку
                          Row(
                            children: [
                              Expanded(
                                child: _buildInputField(
                                  controller: _firstNameController,
                                  label: 'Ім\'я',
                                  icon: Icons.person_outline,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Введіть ім\'я';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: _buildInputField(
                                  controller: _lastNameController,
                                  label: 'Прізвище',
                                  icon: Icons.person_outline,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Введіть прізвище';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 20),

                          // Електронна пошта
                          _buildInputField(
                            controller: _emailController,
                            label: 'Електронна пошта',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Будь ласка, введіть електронну пошту';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 20),

                          _buildInputField(
                            controller: _passwordController,
                            label: 'Пароль',
                            icon: Icons.lock_outline,
                            isPassword: true,
                            validator: (value) {
                              String? error =
                                  FormValidation.validatePassword(value!);
                              return error;
                            },
                          ),
                          SizedBox(height: 20),
                          _buildInputField(
                            controller: _confirmPasswordController,
                            label: 'Підтвердження паролю',
                            icon: Icons.lock_outline,
                            isPassword: true,
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

                          SizedBox(height: 20),

                          // Дата народження
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFF5F1EB),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Color(0xFFD4C4B0),
                                width: 1,
                              ),
                            ),
                            child: TextFormField(
                              controller: _dateController,
                              decoration: InputDecoration(
                                labelText: 'Дата народження',
                                labelStyle: TextStyle(color: Color(0xFF8B6F47)),
                                hintText: 'Виберіть дату',
                                hintStyle: TextStyle(
                                    color: Color(0xFF8B6F47).withOpacity(0.6)),
                                prefixIcon: Icon(
                                  Icons.calendar_today_outlined,
                                  color: Color(0xFF8B6F47),
                                ),
                                suffixIcon: Icon(
                                  Icons.arrow_drop_down,
                                  color: Color(0xFF8B6F47),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                              ),
                              readOnly: true,
                              onTap: () => _selectDate(context),
                              validator: (value) {
                                String? error =
                                    FormValidation.validateAge(_selectedDate);
                                return error;
                              },
                            ),
                          ),

                          SizedBox(height: 30),

                          // Кнопка реєстрації
                          Container(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF8B6F47),
                                foregroundColor: Colors.white,
                                elevation: 8,
                                shadowColor: Color(0xFF8B6F47).withOpacity(0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                'Зареєструватися',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  // Кнопка входу
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Color(0xFFD4C4B0),
                        width: 1,
                      ),
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'Уже є акаунт? ',
                          style: TextStyle(
                            color: Color(0xFF8B6F47),
                            fontSize: 16,
                          ),
                          children: [
                            TextSpan(
                              text: 'Увійти',
                              style: TextStyle(
                                color: Color(0xFF5D4E37),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false, // замість obscureText
    required String? Function(String?) validator,
  }) {
    bool _obscureText = isPassword;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          decoration: BoxDecoration(
            color: Color(0xFFF5F1EB),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Color(0xFFD4C4B0),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: _obscureText,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: Color(0xFF8B6F47)),
              prefixIcon: Icon(
                icon,
                color: Color(0xFF8B6F47),
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Color(0xFF8B6F47),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              errorStyle: TextStyle(
                color: Colors.red[700],
                fontSize: 12,
              ),
            ),
            style: TextStyle(
              color: Color(0xFF5D4E37),
              fontSize: 16,
            ),
            validator: validator,
          ),
        );
      },
    );
  }
}
