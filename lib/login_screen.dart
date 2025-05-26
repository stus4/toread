import 'package:flutter/material.dart';
import 'home_screen.dart'; // Імпортуємо HomeScreen
import 'app_styles.dart'; // Імпортуємо всі стилі
import 'colors.dart';
import 'RegistrationScreen.dart'; // Імпортуємо екран реєстрації
import 'auth_service.dart'; // Імпортуємо AuthService

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
        final userId = await AuthService().login(
          _emailController.text,
          _passwordController.text,
        );

        if (userId != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(userId: userId),
            ),
          );
        } else {
          setState(() {
            error = 'Невірний логін або пароль';
            isLoading = false;
          });
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
      appBar: AppBar(
        title: Text('Вхід'),
        backgroundColor: AppColors.anotherbrown, // Колір AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
                  if (value == null || value.isEmpty) {
                    return 'Будь ласка, введіть пароль';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30.0),
              isLoading
                  ? CircularProgressIndicator() // Показуємо індикатор завантаження під час авторизації
                  : ElevatedButton(
                      onPressed: _login,
                      style: AppStyles.elevatedButtonStyle,
                      child: Text('Увійти'),
                    ),
              SizedBox(height: 20.0),
              error != null
                  ? Text(error!, style: TextStyle(color: Colors.red))
                  : SizedBox(),
              SizedBox(height: 20.0),
              TextButton(
                onPressed: () {
                  // Перехід на сторінку відновлення паролю
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Забули пароль?'),
                        content: Text(
                            'Введіть вашу електронну пошту для відновлення паролю.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Закрити'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Логіка для відновлення паролю
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Інструкції надіслано на вашу електронну пошту')),
                              );
                              Navigator.of(context).pop();
                            },
                            child: Text('Відновити'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text('Забули пароль?'),
              ),
              SizedBox(height: 20.0),
              TextButton(
                onPressed: () {
                  // Перехід на сторінку реєстрації
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RegistrationScreen()),
                  );
                },
                child: Text('Немає акаунту? Зареєструватися'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
