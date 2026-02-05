import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:toread/models/recommendation.dart';
import '../../config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toread/models/chapter.dart';
import 'chapter_screen.dart';

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
  String? expandedChapterId; // ID розгорнутого розділу
  Map<String, String> chapterContents = {}; // кеш тексту
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
      Uri.parse('$baseUrl/chapters/work/${widget.work.id}'), // <- правильно
    );

    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      chapters = data.map((e) => Chapter.fromJson(e)).toList();
    } else {
      chapters = [];
    }

    setState(() {
      isLoadingChapters = false;
    });
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
    if (userId == null) return;

    final response = await http.post(
      Uri.parse(
        '$baseUrl/interactions/${widget.work.id}/view?user_id=$userId',
      ),
    );

    if (response.statusCode == 200) {
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
      Uri.parse(
        '$baseUrl/interactions/${widget.work.id}/like?user_id=$userId',
      ),
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
      Uri.parse(
        '$baseUrl/interactions/${widget.work.id}/save?user_id=$userId',
      ),
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
      backgroundColor: const Color(0xFFFAF8F5), // М'який кремовий фон
      appBar: AppBar(
        title: Text(
          widget.work.title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B5B73),
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFFF0EDE6),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF6B5B73)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFE8DDD4),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Інформація про автора
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F4F1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEDE7E0), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Автор: ${widget.work.author}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5D4E75),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Жанри: ${widget.work.genres.join(', ')}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF8B7D8B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Теги: ${widget.work.tags.join(', ')}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF8B7D8B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Опис
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B5B73).withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                widget.work.description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF5D4E75),
                  height: 1.6,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Статистика з кнопками
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF0EDE6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatButton(
                    Icons.favorite, // активна іконка
                    likes,
                    toggleLike,
                    isLiked,
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: const Color(0xFFE8DDD4),
                  ),
                  _buildStatDisplay(Icons.visibility_outlined, views),
                  Container(
                    width: 1,
                    height: 24,
                    color: const Color(0xFFE8DDD4),
                  ),
                  _buildStatButton(
                    Icons.bookmark_border,
                    saved,
                    toggleSaved,
                    isSaved,
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: const Color(0xFFE8DDD4),
                  ),
                  _buildStatDisplay(Icons.menu_book_outlined, widget.work.read),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Заголовок "Розділи"
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 16),
              child: Text(
                "Розділи",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF5D4E75),
                  letterSpacing: 0.3,
                ),
              ),
            ),

            isLoadingChapters
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF8B7D8B)),
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : chapters.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F4F1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: const Color(0xFFEDE7E0), width: 1),
                        ),
                        child: Text(
                          'Розділів поки що немає',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF8B7D8B),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : Column(
                        children: chapters.asMap().entries.map((entry) {
                          final index = entry.key;
                          final chapter = entry.value;
                          final isExpanded = expandedChapterId == chapter.id;

                          return Column(
                            children: [
                              Container(
                                margin: EdgeInsets.only(bottom: 0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6B5B73)
                                          .withOpacity(0.06),
                                      blurRadius: 12,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () async {
                                      if (isExpanded) {
                                        // Згортання
                                        setState(() {
                                          expandedChapterId = null;
                                        });
                                      } else {
                                        // Завантажити текст, якщо ще не завантажено
                                        if (!chapterContents
                                            .containsKey(chapter.id)) {
                                          final response = await http.get(Uri.parse(
                                              '$baseUrl/chapters/item/${chapter.id}'));
                                          if (response.statusCode == 200) {
                                            final data =
                                                jsonDecode(response.body);
                                            chapterContents[chapter.id] =
                                                data['content'] ?? '';
                                          } else {
                                            chapterContents[chapter.id] =
                                                'Помилка при завантаженні розділу';
                                          }
                                        }

                                        setState(() {
                                          expandedChapterId = chapter.id;
                                        });
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF0EDE6),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${chapter.num + 1}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF6B5B73),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  chapter.title,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF5D4E75),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            isExpanded
                                                ? Icons.keyboard_arrow_up
                                                : Icons.keyboard_arrow_down,
                                            color: const Color(0xFFB8A9C9),
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Текст розділу під контейнером
                              if (isExpanded)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7F4F1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFFEDE7E0)),
                                  ),
                                  child: Text(
                                    chapterContents[chapter.id] ?? '',
                                    style: const TextStyle(
                                        fontSize: 16, height: 1.6),
                                  ),
                                ),
                            ],
                          );
                        }).toList(),
                      )
          ],
        ),
      ),
    );
  }
}
