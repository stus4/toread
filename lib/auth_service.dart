import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class AuthService {
  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['userId'] != null) {
          return data['userId'].toString(); // Повертаємо userId
        } else {
          throw Exception('Сервер не повернув userId');
        }
      } else if (response.statusCode == 401) {
        final data = json.decode(response.body);
        throw Exception(data['detail'] ?? 'Невірні логін або пароль');
      } else {
        throw Exception('Сервер повернув помилку: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception(
          'Помилка з’єднання: сервер недоступний або відсутнє інтернет-з’єднання.');
    } catch (e) {
      throw Exception('Помилка зʼєднання або обробки запиту: $e');
    }
  }
}
