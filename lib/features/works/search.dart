import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config.dart';
import 'work_detail_screen.dart';
import '../../models/recommendation.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Recommendation? openedWork;
  String query = "";
  final TextEditingController _controller = TextEditingController();
  List<dynamic> results = [];
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
      final response = await http.get(url); // заміни localhost на IP сервера
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          results = data;
        });
      } else {
        // Обробка помилки від сервера
        setState(() {
          results = [];
        });
      }
    } catch (e) {
      // Обробка помилки з мережею
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
            // Search Field Container
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
                      ? Container(
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFF8B4513).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Color(0xFF8B4513),
                              size: 20,
                            ),
                            onPressed: () {
                              _controller.clear();
                              setState(() {
                                query = "";
                                results = [];
                              });
                            },
                          ),
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
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF5D4037),
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

            // Results Area
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B4513)),
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Пошук...',
              style: TextStyle(
                color: Color(0xFF8B4513),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Color(0xFF8B4513).withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.search,
                size: 48,
                color: Color(0xFF8B4513).withOpacity(0.5),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Введіть текст для пошуку',
              style: TextStyle(
                color: Color(0xFF8B4513).withOpacity(0.7),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Почніть вводити назву твору, автора або теги',
              style: TextStyle(
                color: Color(0xFF8B4513).withOpacity(0.5),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Color(0xFF8B4513).withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.search_off,
                size: 48,
                color: Color(0xFF8B4513).withOpacity(0.5),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Результатів не знайдено',
              style: TextStyle(
                color: Color(0xFF8B4513).withOpacity(0.7),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Спробуйте змінити пошуковий запит',
              style: TextStyle(
                color: Color(0xFF8B4513).withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results Header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'Знайдено результатів: ${results.length}',
            style: TextStyle(
              color: Color(0xFF8B4513),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 8),

        // Results List
        Expanded(
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              return _buildWorkCard(results[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWorkCard(Map<String, dynamic> work) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        final openedWork = Recommendation.fromJson(work);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  WorkDetailScreen(work: openedWork!, workId: openedWork!.id)),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF8B4513).withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              // Header with title and author
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFE8DCC0),
                      Color(0xFFF0ECE8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      work['title'] ?? 'Без назви',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8B4513),
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: Color(0xFF8B4513).withOpacity(0.7),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Автор: ${work['author'] ?? 'Невідомий'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8B4513).withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    if (work['description'] != null &&
                        work['description'].toString().isNotEmpty) ...[
                      _buildInfoRow(
                        Icons.description_outlined,
                        'Опис',
                        work['description'],
                      ),
                      SizedBox(height: 12),
                    ],

                    // Status
                    _buildInfoRow(
                      Icons.info_outline,
                      'Статус',
                      work['status'] ?? 'Невідомо',
                    ),
                    SizedBox(height: 12),

                    // Categories
                    if (work['categories'] != null &&
                        (work['categories'] as List).isNotEmpty) ...[
                      _buildTagsRow(
                        Icons.category_outlined,
                        'Категорії',
                        (work['categories'] as List<dynamic>)
                            .map((e) => e.toString())
                            .toList(),
                        Color(0xFFE8DCC0),
                      ),
                      SizedBox(height: 12),
                    ],

                    // Tags
                    if (work['tags'] != null &&
                        (work['tags'] as List).isNotEmpty) ...[
                      _buildTagsRow(
                        Icons.tag,
                        'Теги',
                        (work['tags'] as List<dynamic>)
                            .map((e) => e.toString())
                            .toList(),
                        Color(0xFFF0ECE8),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 2),
          child: Icon(
            icon,
            size: 16,
            color: Color(0xFF8B4513).withOpacity(0.7),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8B4513),
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5D4037),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsRow(
      IconData icon, String label, List<String> tags, Color chipColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Color(0xFF8B4513).withOpacity(0.7),
            ),
            SizedBox(width: 8),
            Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8B4513),
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: tags
              .map((tag) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: chipColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xFF8B4513).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8B4513),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
