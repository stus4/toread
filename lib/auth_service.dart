import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.2:8000/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['userId'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_id', data['userId'].toString());
          return data['userId'].toString(); // Повертаємо userId
        } else {
          throw Exception('Сервер не повернув userId');
        }
      } else if (response.statusCode == 401) {
        // Обробка 401 — невірні дані
        try {
          final data = json.decode(response.body);
          throw Exception(data['detail'] ?? 'Невірні логін або пароль');
        } catch (_) {
          final message = utf8.decode(response.bodyBytes, allowMalformed: true);
          throw Exception('Помилка авторизації: $message');
        }
      } else {
        // Інші коди помилок
        String message;
        try {
          message = json.decode(response.body)['detail'] ?? response.body;
        } catch (_) {
          message = utf8.decode(response.bodyBytes, allowMalformed: true);
        }
        throw Exception(
            'Сервер повернув помилку ${response.statusCode}: $message');
      }
    } on SocketException {
      throw Exception(
          'Помилка з’єднання: сервер недоступний або відсутнє інтернет-з’єднання.');
    } catch (e) {
      throw Exception('Помилка зʼєднання або обробки запиту: $e');
    }
  }
}
