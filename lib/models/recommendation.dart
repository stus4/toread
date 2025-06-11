import 'dart:convert';
import 'package:http/http.dart' as http;

class Recommendation {
  final String id;
  final String title;
  final String author;
  final List<String> genres;
  final List<String> tags;
  final String description;
  final int likes;
  final int views;
  final int saved;
  final int read;

  Recommendation({
    required this.id,
    required this.title,
    required this.author,
    required this.genres,
    required this.tags,
    required this.description,
    required this.likes,
    required this.views,
    required this.saved,
    required this.read,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null) {
      throw Exception('Відсутній параметр id у Recommendation JSON');
    }
    return Recommendation(
      id: json['id'],
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      genres: List<String>.from(json['genres'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      description: json['description'] ?? '',
      likes: json['likes'] ?? 0,
      views: json['views'] ?? 0,
      saved: json['saved'] ?? 0,
      read: json['read'] ?? 0,
    );
  }
}

Future<List<Recommendation>> fetchRecommendations(String userId) async {
  final response = await http
      .get(Uri.parse('http://192.168.170.157:8000/recommendations/$userId'));

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
    return data.map((item) => Recommendation.fromJson(item)).toList();
  } else {
    throw Exception('Не вдалося завантажити рекомендації');
  }
}

Future<List<Recommendation>> fetchPopularWorks() async {
  final response = await http.get(
    Uri.parse('http://192.168.170.157:8000/popular'),
  );

  if (response.statusCode == 200) {
    print('Response body: ${utf8.decode(response.bodyBytes)}');
    final jsonResponse = json.decode(utf8.decode(response.bodyBytes));

    // Якщо приходить масив
    if (jsonResponse is List) {
      return jsonResponse.map((item) => Recommendation.fromJson(item)).toList();
    }

    // Якщо приходить об'єкт з масивом всередині, наприклад, 'results'
    else if (jsonResponse is Map && jsonResponse.containsKey('results')) {
      List<dynamic> data = jsonResponse['results'];
      return data.map((item) => Recommendation.fromJson(item)).toList();
    } else {
      throw Exception('Невідомий формат відповіді від сервера');
    }
  } else {
    throw Exception('Не вдалося завантажити популярні твори');
  }
}
