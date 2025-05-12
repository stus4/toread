import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:toread/models/recommendation.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Recommendation>> recommendations;

  @override
  void initState() {
    super.initState();
    // Викликаємо метод для завантаження рекомендацій
    recommendations = fetchRecommendations();
  }

  // Метод для отримання даних з API
  Future<List<Recommendation>> fetchRecommendations() async {
    final response = await http
        .get(Uri.parse('http://127.0.0.1:8000/recommendations/your_user_id'));

    if (response.statusCode == 200) {
      // Якщо сервер повертає відповідь, то парсимо її
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => Recommendation.fromJson(item)).toList();
    } else {
      throw Exception('Не вдалося завантажити рекомендації');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Головна сторінка'),
      ),
      body: FutureBuilder<List<Recommendation>>(
        future: recommendations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Помилка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Немає доступних рекомендацій'));
          } else {
            // Виводимо список рекомендацій
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final recommendation = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(recommendation.title),
                    subtitle: Text(recommendation.description),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
