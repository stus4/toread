import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  Future<bool> login(String email, String password) async {
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
        return data['success'] == true;
      } else if (response.statusCode == 401) {
        final data = json.decode(response.body);
        throw Exception(data['detail'] ?? 'Невірні логін або пароль');
      } else {
        throw Exception('Сервер повернув помилку: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Помилка зʼєднання або обробки запиту: $e');
    }
  }
}
