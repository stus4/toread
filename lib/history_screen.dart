// history_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'models/recommendation.dart'; // файл з класом Recommendation

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
      appBar: AppBar(title: Text('Історія переглядів')),
      body: FutureBuilder<List<Recommendation>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Помилка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Історія порожня'));
          } else {
            final history = snapshot.data!;
            return ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return ListTile(
                  title: Text(item.title),
                  subtitle: Text(
                      'Автор: ${item.author}\nЖанри: ${item.genres.join(", ")}'),
                  isThreeLine: true,
                  onTap: () {
                    // Тут можна зробити перехід до детального перегляду твору
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
