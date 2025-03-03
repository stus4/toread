import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Welcome to the Login Screen!'),
            SizedBox(height: 20),
            // Можна додати поля для вводу та кнопку входу
          ],
        ),
      ),
    );
  }
}
