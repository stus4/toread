import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:toread/models/recommendation.dart';
import 'config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toread/models/chapter.dart';

class WorkDetailScreen extends StatefulWidget {
  final Recommendation work;
  final String workId;

  const WorkDetailScreen({
    Key? key,
    required this.work,
    required this.workId,
  }) : super(key: key);

  @override
  _WorkDetailScreenState createState() => _WorkDetailScreenState();
}

class _WorkDetailScreenState extends State<WorkDetailScreen> {
  late int likes;
  late int saved;
  late int views;
  late bool isLiked;
  late bool isSaved;
  String? userId;
  List<Chapter> chapters = [];

  bool isLoadingChapters = true;

  @override
  void initState() {
    super.initState();
    likes = widget.work.likes;
    saved = widget.work.saved;
    views = widget.work.views; // ініціалізація

    isLiked = false; // або отримати з API
    isSaved = false; // або отримати з API
    // <- завантажує стан
    _loadUserId();
    fetchChapters();
  }

  Future<void> fetchChapters() async {
    final response = await http.get(
      Uri.parse('$baseUrl/works/${widget.work.id}/chapters'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        chapters = data.map((e) => Chapter.fromJson(e)).toList();
        isLoadingChapters = false;
      });
    } else {
      print('Не вдалося завантажити розділи: ${response.statusCode}');
      setState(() {
        isLoadingChapters = false;
      });
    }
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('user_id');
    setState(() {
      userId = id;
    });

    if (userId != null) {
      fetchUserInteraction(); // завантажити стани
      markAsViewed(); // <- додано тут
    }
  }

  Future<void> markAsViewed() async {
    if (userId == null) {
      print('user_id is null!');
      return;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/interactions/${widget.work.id}/view'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userId),
    );

    if (response.statusCode == 200) {
      print('Перегляд записано');
      await fetchUserInteraction();
    } else {
      print('Помилка при записі перегляду: ${response.statusCode}');
    }
  }

  Future<void> fetchUserInteraction() async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/interactions/${widget.work.id}/status?user_id=$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        likes = data['likes'];
        saved = data['saved'];
        views = data['views'];
        isLiked = data['is_liked'];
        isSaved = data['is_saved'];
      });
    } else {
      print('Не вдалося завантажити статус взаємодії: ${response.statusCode}');
    }
  }

  Future<void> toggleLike() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      print('user_id is null!');
      return;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/interactions/${widget.work.id}/like'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userId),
    );

    if (response.statusCode == 200) {
      // Після лайку оновити повністю статус взаємодії
      await fetchUserInteraction();
    } else {
      print('Помилка при лайкуванні: ${response.statusCode}');
    }
  }

  Future<void> toggleSaved() async {
    final response = await http.post(
      Uri.parse('$baseUrl/works/${widget.work.id}/save'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Оновлюємо повністю статус з сервера
      await fetchUserInteraction();
    }
  }

  Widget _buildStatButton(
    IconData icon,
    int count,
    VoidCallback onPressed,
    bool active,
  ) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            active ? icon : _getInactiveIcon(icon),
            color: active ? Colors.red : Colors.grey,
          ),
          onPressed: onPressed,
        ),
        Text('$count'),
      ],
    );
  }

// Допоміжна функція, яка повертає «порожній» варіант іконки для активної пари
  IconData _getInactiveIcon(IconData icon) {
    if (icon == Icons.favorite) return Icons.favorite_border;
    if (icon == Icons.bookmark) return Icons.bookmark_border;
    // додай інші іконки, якщо потрібно
    return icon;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildStatButton(
                  Icons.favorite,
                  likes,
                  toggleLike,
                  isLiked,
                ),
                SizedBox(width: 16),
                _buildStatDisplay(Icons.visibility, views),
                SizedBox(width: 16),
                _buildStatButton(
                  Icons.bookmark,
                  saved,
                  toggleSaved,
                  isSaved,
                ),
                SizedBox(width: 16),
                _buildStatDisplay(Icons.menu_book, widget.work.read),
              ],
            ),
            Text('Розділи:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),

            isLoadingChapters
                ? CircularProgressIndicator()
                : chapters.isEmpty
                    ? Text('Розділів немає')
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: chapters.length,
                        separatorBuilder: (_, __) => Divider(),
                        itemBuilder: (context, index) {
                          final chapter = chapters[index];
                          return ListTile(
                            title: Text(chapter.title),
                            subtitle: Text('Розділ №${chapter.num + 1}'),
                            onTap: () {
                              // Навігація до конкретного розділу, якщо треба
                            },
                          );
                        },
                      ),

            // Статистика з кнопками
          ],
        ),
      ),
    );
  }
}
