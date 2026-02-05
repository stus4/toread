import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config.dart';
import '../../models/recommendation.dart';
import '../works/work_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  final String userId;

  const HistoryScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Recommendation>> _historyFuture;

  Future<List<Recommendation>> fetchHistory(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/history/$userId'),
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      print(decoded); // для дебагу

      List<dynamic> data = [];

      if (decoded is List) {
        data = decoded;
      } else if (decoded is Map && decoded['history'] != null) {
        data = decoded['history'];
      } else {
        return [];
      }

      // Замінюємо author_user об’єкт на рядок author = username
      final List<Map<String, dynamic>> modifiedData =
          data.map<Map<String, dynamic>>((item) {
        final newItem = Map<String, dynamic>.from(item);
        if (newItem['author_user'] != null &&
            newItem['author_user'] is Map<String, dynamic>) {
          newItem['author'] = newItem['author_user']['username'] ?? '';
        } else {
          newItem['author'] = '';
        }
        return newItem;
      }).toList();

      return modifiedData.map((item) => Recommendation.fromJson(item)).toList();
    } else {
      throw Exception('Не вдалося завантажити історію');
    }
  }

  @override
  void initState() {
    super.initState();
    _historyFuture = fetchHistory(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5), // М'який кремовий фон
      appBar: AppBar(
        title: const Text(
          'Історія переглядів',
          style: TextStyle(
            color: Color(0xFF5D4E42),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFFE6D7C8),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xFF5D4E42),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Recommendation>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4C4B0)),
                strokeWidth: 3,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Container(
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EBE4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE1D5C7),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFF8A7968),
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Помилка: ${snapshot.error}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF8A7968),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Container(
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EBE4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE1D5C7),
                    width: 1,
                  ),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history,
                      color: Color(0xFF8A7968),
                      size: 64,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Історія порожня',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B5B4D),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Переглянуті роботи з\'являться тут',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8A7968),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            final history = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F0E8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE5D8C8),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFCBB896).withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WorkDetailScreen(
                                work: item,
                                workId: item.id.toString(),
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Декоративний індикатор
                              Container(
                                width: 4,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD4C4B0),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Контент
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF5D4E42),
                                        height: 1.3,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Автор: ${item.author}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF7A6B5D),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (item.genres.isNotEmpty) ...[
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children:
                                            item.genres.take(3).map((genre) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE8DDD2),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: const Color(0xFFD6C8B8),
                                                width: 0.5,
                                              ),
                                            ),
                                            child: Text(
                                              genre,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF6B5B4D),
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      if (item.genres.length > 3)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4),
                                          child: Text(
                                            '+ ще ${item.genres.length - 3}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF8A7968),
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ],
                                ),
                              ),
                              // Стрілка
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Color(0xFFD4C4B0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
