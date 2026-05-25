import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../../core/widgets/animated_loading.dart'; // Імпортуємо HomeScreen
import '../../core/styles/app_styles.dart'; // Імпортуємо всі стилі
import '../../core/styles/colors.dart';
import 'register_screen.dart'; // Імпортуємо екран реєстрації
import '../../core/services/auth_service.dart'; // Імпортуємо AuthService
import 'two_factor_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;
  String? error;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        error = null;
      });

      try {
        final result = await AuthService().login(
          _emailController.text,
          _passwordController.text,
        );

        if (result != null) {
          final userId = result['userId'];
          final need2fa = result['need2fa'];

          if (need2fa == true) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TwoFactorScreen(userId: userId),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SplashScreen(userId: userId),
              ),
            );
          }
        }
      } catch (e) {
        setState(() {
          error = 'Помилка: $e';
          isLoading = false;
        });
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
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Логотип або заголовок
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color(0xFF8B6F47), // Коричневий
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/logodark.png', // Шлях до твого PNG-лого
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                    ),

                    SizedBox(height: 30),

                    Text(
                      'Ласкаво просимо!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D4E37), // Темно-коричневий
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Увійдіть до свого акаунту',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF8B6F47),
                      ),
                    ),
                    SizedBox(height: 40),

                    // Форма в контейнері
                    Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
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
                            // Поле електронної пошти
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
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Електронна пошта',
                                  labelStyle:
                                      TextStyle(color: Color(0xFF8B6F47)),
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: Color(0xFF8B6F47),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Будь ласка, введіть електронну пошту';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            SizedBox(height: 20),

                            // Поле паролю
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
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Пароль',
                                  labelStyle:
                                      TextStyle(color: Color(0xFF8B6F47)),
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: Color(0xFF8B6F47),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Будь ласка, введіть пароль';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            SizedBox(height: 30),

                            // Кнопка входу
                            Container(
                              width: double.infinity,
                              height: 55,
                              child: isLoading
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Color(0xFF8B6F47),
                                        ),
                                      ),
                                    )
                                  : ElevatedButton(
                                      onPressed: _login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF8B6F47),
                                        foregroundColor: Colors.white,
                                        elevation: 5,
                                        shadowColor:
                                            Colors.black.withOpacity(0.3),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                      child: Text(
                                        'Увійти',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                            ),

                            SizedBox(height: 20),

                            // Повідомлення про помилку
                            if (error != null)
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.red.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  error!,
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 30),

                    // Кнопка "Забули пароль?"
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Color(0xFFF5F1EB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: Text(
                                'Забули пароль?',
                                style: TextStyle(
                                  color: Color(0xFF5D4E37),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Text(
                                'Введіть вашу електронну пошту для відновлення паролю.',
                                style: TextStyle(color: Color(0xFF8B6F47)),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'Закрити',
                                    style: TextStyle(color: Color(0xFF8B6F47)),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Інструкції надіслано на вашу електронну пошту',
                                        ),
                                        backgroundColor: Color(0xFF8B6F47),
                                      ),
                                    );
                                    Navigator.of(context).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF8B6F47),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    'Відновити',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text(
                        'Забули пароль?',
                        style: TextStyle(
                          color: Color(0xFF8B6F47),
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    SizedBox(height: 10),

                    // Кнопка реєстрації
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegistrationScreen(),
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'Немає акаунту? ',
                          style: TextStyle(
                            color: Color(0xFF8B6F47),
                            fontSize: 16,
                          ),
                          children: [
                            TextSpan(
                              text: 'Зареєструватися',
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
