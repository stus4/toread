import 'package:http/http.dart' as http;
import 'dart:convert';

class DatabaseService {
  Future<String?> fetchFirstCategory() async {
    try {
      final response =
          await http.get(Uri.parse('http://127.0.0.1:8000/first-category'));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['firstCategory'];
      } else {
        throw Exception('Помилка: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Помилка зʼєднання: $e');
    }
  }
}
