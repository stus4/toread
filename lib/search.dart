import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
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
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Пошук',
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  setState(() {
                    query = "";
                    results = [];
                  });
                },
              ),
            ),
            onChanged: (value) {
              setState(() {
                query = value;
              });
              searchWorks(value);
            },
          ),
          SizedBox(height: 20),
          if (isLoading)
            Center(child: CircularProgressIndicator())
          else if (query.isEmpty)
            Center(child: Text('Введіть текст для пошуку'))
          else if (results.isEmpty)
            Center(child: Text('Результатів не знайдено'))
          else
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final work = results[index];
                  return ListTile(
                    title: Text(work['title'] ?? 'Без назви'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Автор: ${work['author'] ?? 'Невідомий'}'),
                        Text('Опис: ${work['description'] ?? 'Немає опису'}'),
                        Text('Статус: ${work['status'] ?? 'Невідомо'}'),
                        Text(
                            'Категорії: ${(work['categories'] as List<dynamic>?)?.join(", ") ?? "—"}'),
                        Text(
                            'Теги: ${(work['tags'] as List<dynamic>?)?.join(", ") ?? "—"}'),
                      ],
                    ),
                    isThreeLine: true,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
