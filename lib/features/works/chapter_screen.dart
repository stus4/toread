import 'package:flutter/material.dart';
import '../../models/chapter.dart';
import 'package:http/http.dart' as http;
import '../../config.dart'; // щоб був baseUrl
import 'dart:convert';

class ChapterScreen extends StatefulWidget {
  final String chapterId;

  const ChapterScreen({Key? key, required this.chapterId}) : super(key: key);

  @override
  _ChapterScreenState createState() => _ChapterScreenState();
}

Future<Chapter> fetchChapter(String chapterId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/chapters/$chapterId'),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return Chapter.fromJson(data);
  } else {
    throw Exception('Не вдалося завантажити розділ');
  }
}

class _ChapterScreenState extends State<ChapterScreen> {
  late Future<Chapter> chapter;

  @override
  void initState() {
    super.initState();
    chapter = fetchChapter(widget.chapterId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Розділ'),
        backgroundColor: const Color(0xFFE8DDD4),
        iconTheme: const IconThemeData(color: Color(0xFF5D4E75)),
      ),
      body: FutureBuilder<Chapter>(
        future: chapter,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Помилка: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Розділ не знайдено'));
          } else {
            final chapterData = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapterData.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    chapterData.content ?? '',
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
