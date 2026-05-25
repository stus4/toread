import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config.dart';

class AuthService {
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
  }

  Future<Map<String, dynamic>?> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();

        final userId = data['userId'].toString();
        final need2fa = data['need_2fa'] ?? false;

        // ⚠️ НЕ зберігаємо user_id якщо є 2FA
        if (!need2fa) {
          await prefs.setString('user_id', userId);
        }

        return {
          'userId': userId,
          'need2fa': need2fa,
          'message': data['message'],
        };
      }

      if (response.statusCode == 401) {
        throw Exception(data['detail'] ?? 'Невірні дані');
      }

      throw Exception(data['message'] ?? 'Помилка входу');
    } on SocketException {
      throw Exception('Немає зʼєднання з сервером');
    } catch (e) {
      throw Exception('Помилка: $e');
    }
  }
}
