import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config.dart';
import 'work_detail_screen.dart';
import '../../models/recommendation.dart'; // Імпортуємо єдину модель

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = "";
  final TextEditingController _controller = TextEditingController();
  // Змінюємо тип списку на Recommendation для типізації даних
  List<Recommendation> results = [];
  bool isLoading = false;

  Future<void> searchWorks(String query) async {
    if (query.isEmpty) {
      setState(() {
        results = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('$baseUrl/search?title=$query');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          // Перетворюємо кожен елемент JSON на об'єкт моделі Recommendation
          results = data.map((item) => Recommendation.fromJson(item)).toList();
        });
      } else {
        setState(() {
          results = [];
        });
      }
    } catch (e) {
      setState(() {
        results = [];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF5F2E8),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Поле пошуку
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF8B4513).withOpacity(0.1),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Пошук творів...',
                  labelStyle: TextStyle(
                    color: Color(0xFF8B4513).withOpacity(0.7),
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xFF8B4513).withOpacity(0.7),
                    size: 24,
                  ),
                  suffixIcon: query.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Color(0xFF8B4513)),
                          onPressed: () {
                            _controller.clear();
                            setState(() {
                              query = "";
                              results = [];
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Color(0xFF8B4513), width: 2),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    query = value;
                  });
                  searchWorks(value);
                },
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: _buildResultsArea(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsArea() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: Color(0xFF8B4513)));
    }

    if (query.isEmpty) {
      return _buildEmptyState(Icons.search, 'Введіть текст для пошуку');
    }

    if (results.isEmpty) {
      return _buildEmptyState(Icons.search_off, 'Результатів не знайдено');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Знайдено результатів: ${results.length}',
          style:
              TextStyle(color: Color(0xFF8B4513), fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) => _buildWorkCard(results[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Color(0xFF8B4513).withOpacity(0.3)),
          SizedBox(height: 16),
          Text(message,
              style: TextStyle(color: Color(0xFF8B4513).withOpacity(0.7))),
        ],
      ),
    );
  }

  // Оновлений метод картки, що використовує об'єкт Recommendation
  Widget _buildWorkCard(Recommendation work) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WorkDetailScreen(work: work, workId: work.id),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFE8DCC0).withOpacity(0.3),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    work.title, // Доступ через властивість об'єкта
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513)),
                  ),
                  Text('Автор: ${work.author}',
                      style: TextStyle(color: Colors.brown)),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  if (work.description.isNotEmpty)
                    _buildInfoRow(Icons.description, 'Опис', work.description),
                  if (work.genres.isNotEmpty)
                    _buildTagsRow(Icons.category, 'Жанри', work.genres,
                        Color(0xFFE8DCC0)),
                  if (work.tags.isNotEmpty)
                    _buildTagsRow(
                        Icons.tag, 'Теги', work.tags, Color(0xFFF0ECE8)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.brown),
          SizedBox(width: 8),
          Expanded(
              child: Text('$label: $value', style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildTagsRow(
      IconData icon, String label, List<String> tags, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Icon(icon, size: 16), SizedBox(width: 8), Text(label)]),
        SizedBox(height: 4),
        Wrap(
          spacing: 6,
          children: tags
              .map((tag) => Chip(
                    label: Text(tag, style: TextStyle(fontSize: 12)),
                    backgroundColor: color,
                    visualDensity: VisualDensity.compact,
                  ))
              .toList(),
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
