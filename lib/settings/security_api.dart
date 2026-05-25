import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../core/services/user_session.dart';

class SecurityApi {
  final String baseUrl;

  SecurityApi(this.baseUrl);
  Future<void> disable2FA(String userId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/2fa/disable?user_id=$userId'),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to disable 2FA");
    }
  }

  Future<bool> get2FAStatus(String userId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/users/user/$userId'),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load user");
    }

    final data = jsonDecode(res.body);
    return data["twofa_enabled"] ?? false;
  }

  Future<Uint8List> setup2FA(String userId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/2fa/setup?user_id=$userId'),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to setup 2FA");
    }

    return res.bodyBytes;
  }

  Future<Map<String, dynamic>> verify2FALogin(
    String userId,
    String code,
  ) async {
    final res = await http.post(
      Uri.parse(
        '$baseUrl/2fa/verify-login?user_id=$userId&code=$code',
      ),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to verify 2FA login");
    }

    return jsonDecode(res.body);
  }

  Future<void> enable2FA(
    String userId,
    String code,
  ) async {
    final res = await http.post(
      Uri.parse(
        '$baseUrl/2fa/enable?user_id=$userId&code=$code',
      ),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to enable 2FA");
    }
  }
}
