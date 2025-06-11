// history_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
      Uri.parse('http://192.168.1.2:8000/history/$userId'),
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      print(decoded); // подивись, що саме повертає сервер

      // Якщо сервер повертає масив
      if (decoded is List) {
        return decoded.map((item) => Recommendation.fromJson(item)).toList();
      }
      // Якщо сервер повертає об'єкт із ключем history
      else if (decoded is Map && decoded['history'] != null) {
        final List<dynamic> data = decoded['history'];
        return data.map((item) => Recommendation.fromJson(item)).toList();
      }
      // Якщо структура інша — повертаємо пустий список
      else {
        return [];
      }
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
