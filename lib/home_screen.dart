import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:toread/models/recommendation.dart';
import 'create_work_screen.dart';
import 'history_screen.dart';
import 'search.dart';
import 'filter_dialog.dart';
import 'account_screen.dart';
import 'work_detail_screen.dart';
import 'config.dart';
import 'profile.dart';

// Заглушка для екрана сповіщень
class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Сповіщення")),
      body: Center(child: Text("Тут будуть сповіщення")),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String userId;

  HomeScreen({required this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Recommendation? openedWork;

  late Future<List<Recommendation>> recommendations;
  late Future<List<Recommendation>> popularWorks;
  int _selectedIndex = 0;
  String? selectedFilter; // наприклад, жанр або тег
  String? selectedSort; // наприклад, за популярністю, датою

  @override
  void initState() {
    super.initState();
    recommendations = fetchRecommendations(widget.userId);
    popularWorks = fetchPopularWorks();
  }

  Future<List<Recommendation>> fetchRecommendations(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/recommendations/$userId'),
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      print('Response recommendations: $decoded');

      // Перевіряємо, що decoded - це список
      if (decoded is List) {
        return decoded.map((item) => Recommendation.fromJson(item)).toList();
      }
      // Якщо це Map з ключем 'recommendations' або іншим
      else if (decoded is Map && decoded['recommendations'] != null) {
        final data = decoded['recommendations'] as List<dynamic>;
        return data.map((item) => Recommendation.fromJson(item)).toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Не вдалося завантажити рекомендації');
    }
  }

  Future<List<Recommendation>> fetchPopularWorks() async {
    final response = await http.get(
      Uri.parse('$baseUrl/popular'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((item) => Recommendation.fromJson(item)).toList();
    } else {
      throw Exception('Не вдалося завантажити популярні твори');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildCard(Recommendation recommendation) {
    return GestureDetector(
      onTap: () {
        setState(() {
          openedWork = recommendation;
        });
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: ListTile(
          title: Text(recommendation.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Автор: ${recommendation.author}'),
              Text('Жанри: ${recommendation.genres.join(', ')}'),
              Text('Теги: ${recommendation.tags.join(', ')}'),
              Text(recommendation.description),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildStatIcon(Icons.thumb_up, recommendation.likes),
                  SizedBox(width: 16),
                  _buildStatIcon(Icons.visibility, recommendation.views),
                  SizedBox(width: 16),
                  _buildStatIcon(Icons.bookmark, recommendation.saved),
                  SizedBox(width: 16),
                  _buildStatIcon(Icons.menu_book, recommendation.read),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatIcon(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 4),
        Text(count.toString(), style: TextStyle(color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Популярне
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Популярне',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              SizedBox(
                height: 240,
                child: FutureBuilder<List<Recommendation>>(
                  future: popularWorks,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Помилка: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('Немає популярних творів'));
                    } else {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final recommendation = snapshot.data![index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                openedWork = recommendation;
                              });
                            },
                            child: Container(
                              width: 300,
                              margin: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Card(
                                elevation: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(recommendation.title,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(height: 4),
                                      Text('Автор: ${recommendation.author}'),
                                      Text(
                                          'Жанри: ${recommendation.genres.join(', ')}'),
                                      Text(
                                          'Теги: ${recommendation.tags.join(', ')}'),
                                      SizedBox(height: 4),
                                      Expanded(
                                        child: Text(
                                          recommendation.description,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 4,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          _buildStatIcon(Icons.thumb_up,
                                              recommendation.likes),
                                          SizedBox(width: 12),
                                          _buildStatIcon(Icons.visibility,
                                              recommendation.views),
                                          SizedBox(width: 12),
                                          _buildStatIcon(Icons.bookmark,
                                              recommendation.saved),
                                          SizedBox(width: 12),
                                          _buildStatIcon(Icons.menu_book,
                                              recommendation.read),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),

              // Рекомендоване
              // Вставити перед Padding з текстом 'Рекомендоване для вас'
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  children: [
                    Text('Рекомендоване для вас',
                        style: Theme.of(context).textTheme.titleLarge),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.filter_list),
                      tooltip: 'Фільтр',
                      onPressed: () {
                        _showFilterDialog();
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.sort),
                      tooltip: 'Сортування',
                      onPressed: () {
                        _showSortDialog();
                      },
                    ),
                  ],
                ),
              ),

              FutureBuilder<List<Recommendation>>(
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
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final recommendation = snapshot.data![index];
                        return _buildCard(recommendation);
                      },
                    );
                  }
                },
              ),
            ],
          ),
        );

      case 1:
        return Center(child: Text("Ідеї"));
      case 2:
        return SearchPage();
      case 3:
        return CreateWorkScreen();
      case 4:
        return AccountScreen();
      default:
        return Center(child: Text("Невідома сторінка"));
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return FilterDialog(
          selectedFilter: selectedFilter,
          onFilterSelected: (filter) {
            setState(() {
              selectedFilter = filter;
              // Тут можна додати оновлення рекомендацій згідно фільтра
            });
          },
        );
      },
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Виберіть сортування'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  title: Text('За популярністю'),
                  onTap: () {
                    setState(() {
                      selectedSort = 'popular';
                      // Виклик оновлення рекомендацій з сортуванням
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('За датою'),
                  onTap: () {
                    setState(() {
                      selectedSort = 'date';
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Без сортування'),
                  onTap: () {
                    setState(() {
                      selectedSort = null;
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HistoryScreen(userId: widget.userId)),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsScreen()),
              );
            },
          ),
          if (_selectedIndex == 4)
            IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilePage(userId: widget.userId)),
                );
              },
            ),
        ],
        leading: openedWork != null
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    openedWork = null;
                  });
                },
              )
            : null,
      ),
      body: openedWork != null
          ? WorkDetailScreen(work: openedWork!)
          : _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            openedWork = null; // Закриваємо деталі, якщо була відкрита
            _onItemTapped(index);
          });
        },
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
