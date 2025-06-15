// recommendations_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:toread/models/recommendation.dart';
import 'config.dart';

class RecommendationsService {
  static Future<List<Recommendation>> fetchRecommendations(
      String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/recommendations/$userId'),
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      if (decoded is List) {
        return decoded.map((item) => Recommendation.fromJson(item)).toList();
      } else if (decoded is Map && decoded['recommendations'] != null) {
        final data = decoded['recommendations'] as List<dynamic>;
        return data.map((item) => Recommendation.fromJson(item)).toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Не вдалося завантажити рекомендації');
    }
  }

  static Future<List<Recommendation>> fetchPopularWorks() async {
    final response = await http.get(
      Uri.parse('$baseUrl/popular'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((item) => Recommendation.fromJson(item)).toList();
    } else {
      throw Exception('Не вдалося завантажити популярні твори');
    }
  }
}
