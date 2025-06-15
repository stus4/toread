import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:toread/models/recommendation.dart';
import 'config.dart';

class WorkDetailScreen extends StatefulWidget {
  final Recommendation work;

  WorkDetailScreen({required this.work});

  @override
  _WorkDetailScreenState createState() => _WorkDetailScreenState();
}

class _WorkDetailScreenState extends State<WorkDetailScreen> {
  late int likes;
  late int saved;
  late bool isLiked;
  late bool isSaved;

  @override
  void initState() {
    super.initState();
    likes = widget.work.likes;
    saved = widget.work.saved;
    isLiked = false; // або отримати з API
    isSaved = false; // або отримати з API
  }

  Future<void> toggleLike() async {
    final response = await http.post(
      Uri.parse('$baseUrl/works/${widget.work.id}/like'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      setState(() {
        isLiked = !isLiked;
        likes += isLiked ? 1 : -1;
      });
    }
  }

  Future<void> toggleSaved() async {
    final response = await http.post(
      Uri.parse('$baseUrl/works/${widget.work.id}/save'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      setState(() {
        isSaved = !isSaved;
        saved += isSaved ? 1 : -1;
      });
    }
  }

  Widget _buildStatButton(
      IconData icon, int count, VoidCallback onPressed, bool active) {
    return Row(
      children: [
        IconButton(
          icon: Icon(icon, color: active ? Colors.red : Colors.grey[600]),
          iconSize: 20,
          onPressed: onPressed,
        ),
        Text(count.toString(), style: TextStyle(color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildStatDisplay(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        SizedBox(width: 4),
        Text(count.toString(), style: TextStyle(color: Colors.grey[700])),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.work.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Автор: ${widget.work.author}',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Жанри: ${widget.work.genres.join(', ')}'),
            Text('Теги: ${widget.work.tags.join(', ')}'),
            SizedBox(height: 16),
            Text(widget.work.description),
            SizedBox(height: 24),

            // Статистика з кнопками
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildStatButton(Icons.thumb_up, likes, toggleLike, isLiked),
                SizedBox(width: 16),
                _buildStatDisplay(Icons.visibility, widget.work.views),
                SizedBox(width: 16),
                _buildStatButton(Icons.bookmark, saved, toggleSaved, isSaved),
                SizedBox(width: 16),
                _buildStatDisplay(Icons.menu_book, widget.work.read),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
