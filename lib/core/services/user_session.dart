import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }
}
