import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:toread/models/recommendation.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  HomeScreen({required this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Recommendation>> recommendations;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    recommendations = fetchRecommendations(widget.userId);
  }

  Future<List<Recommendation>> fetchRecommendations(String userId) async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/recommendations/$userId'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((item) => Recommendation.fromJson(item)).toList();
    } else {
      throw Exception('Не вдалося завантажити рекомендації');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Тут можна додати логіку переходу на інші екрани
    });
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0: // Головна
        return FutureBuilder<List<Recommendation>>(
          future: recommendations,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Помилка: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Немає доступних рекомендацій'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final recommendation = snapshot.data![index];
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(recommendation.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Автор: ${recommendation.author}'),
                          Text('Жанри: ${recommendation.genres.join(', ')}'),
                          Text('Теги: ${recommendation.tags.join(', ')}'),
                          Text(recommendation.description),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        );
      case 1:
        return Center(child: Text("Ідеї"));
      case 2:
        return Center(child: Text("Пошук"));
      case 3:
        return Center(child: Text("Написати"));
      case 4:
        return Center(child: Text("Акаунт"));
      default:
        return Center(child: Text("Невідома сторінка"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Головна',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            label: 'Ідеї',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Пошук',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Написати',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Акаунт',
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return "Головна сторінка";
      case 1:
        return "Ідеї";
      case 2:
        return "Пошук";
      case 3:
        return "Написати";
      case 4:
        return "Акаунт";
      default:
        return "";
    }
  }
}
