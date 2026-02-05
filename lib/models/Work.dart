import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config.dart';

class Work {
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

  final bool isLiked;
  final bool isSaved;
  final bool isViewed;
  final bool isRead;

  Work({
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
    required this.isLiked,
    required this.isSaved,
    required this.isViewed,
    required this.isRead,
  });

  factory Work.fromJson(Map<String, dynamic> json) {
    return Work(
      id: json['id'],
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      description: json['description'] ?? '',
      genres: List<String>.from(json['categories'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      likes: json['likes'] ?? 0,
      views: json['views'] ?? 0,
      saved: json['saved'] ?? 0,
      read: json['read'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      isSaved: json['is_saved'] ?? false,
      isViewed: json['is_viewed'] ?? false,
      isRead: json['is_read'] ?? false,
    );
  }
}
