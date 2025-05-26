import 'dart:convert';
import 'package:http/http.dart' as http;

class Recommendation {
  final String id;
  final String title;
  final String description;
  final String author;
  final List<String> genres;
  final List<String> tags;

  Recommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.genres,
    required this.tags,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    try {
      return Recommendation(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        author: json['author'] ?? '',
        genres:
            (json['genres'] as List?)?.map((g) => g.toString()).toList() ?? [],
        tags: (json['tags'] as List?)?.map((t) => t.toString()).toList() ?? [],
      );
    } catch (e) {
      print('⚠️ Recommendation parsing error: $e');
      print('Data: $json');
      rethrow;
    }
  }
}

Future<List<Recommendation>> fetchRecommendations(String userId) async {
  final response = await http
      .get(Uri.parse('http://127.0.0.1:8000/recommendations/$userId'));

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
    return data.map((item) => Recommendation.fromJson(item)).toList();
  } else {
    throw Exception('Не вдалося завантажити рекомендації');
  }
}
