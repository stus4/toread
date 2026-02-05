import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:toread/models/recommendation.dart';
import '../works/create_work_screen.dart';
import 'history_screen.dart';
import '../works/search.dart';
import '../filters/filter_dialog.dart';
import '../profile/account_screen.dart';
import '../works/work_detail_screen.dart';
import '../../config.dart';
import '../profile/profile_screen.dart';
import '../works/ideas.dart';

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
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Обкладинка
              Container(
                width: 70,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFD4C4B0),
                      Color(0xFFC4A484),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.book,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              SizedBox(width: 16),
              // Контент
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5A4037),
                      ),
                    ),
                    SizedBox(height: 6),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFF8B6F47).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Автор: ${recommendation.author}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8B6F47),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Жанри: ${recommendation.genres.join(', ')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFA68B5B),
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Теги: ${recommendation.tags.join(', ')}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFB8956F),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Text(
                      recommendation.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B4E3D),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatIcon(Icons.thumb_up, recommendation.likes),
                        _buildStatIcon(Icons.visibility, recommendation.views),
                        _buildStatIcon(Icons.bookmark, recommendation.saved),
                        _buildStatIcon(Icons.menu_book, recommendation.read),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatIcon(IconData icon, int count) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color(0xFFE8DDD4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Color(0xFF8B6F47)),
          SizedBox(width: 4),
          Text(
            count.toString(),
            style: TextStyle(
              color: Color(0xFF8B6F47),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return Container(
          color: Color(0xFFF5F1EB),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                // Популярне
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFE8DDD4),
                        Color(0xFFF2E7D5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFF8B6F47).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.trending_up,
                          color: Color(0xFF8B6F47),
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Популярне',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5A4037),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 280,
                  child: FutureBuilder<List<Recommendation>>(
                    future: popularWorks,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF8B6F47)),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Container(
                            padding: EdgeInsets.all(16),
                            margin: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Помилка: ${snapshot.error}',
                              style: TextStyle(color: Color(0xFF8B6F47)),
                            ),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Container(
                            padding: EdgeInsets.all(16),
                            margin: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Немає популярних творів',
                              style: TextStyle(color: Color(0xFF8B6F47)),
                            ),
                          ),
                        );
                      } else {
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 8),
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
                                width: 280,
                                margin: EdgeInsets.symmetric(horizontal: 8.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 50,
                                            height: 70,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Color(0xFFD4C4B0),
                                                  Color(0xFFC4A484),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.book,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  recommendation.title,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF5A4037),
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 4),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFF8B6F47)
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                  child: Text(
                                                    recommendation.author,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Color(0xFF8B6F47),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Жанри: ${recommendation.genres.join(', ')}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFFA68B5B),
                                          fontStyle: FontStyle.italic,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Теги: ${recommendation.tags.join(', ')}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFFB8956F),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 8),
                                      Expanded(
                                        child: Text(
                                          recommendation.description,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF6B4E3D),
                                            height: 1.4,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 4,
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildStatIcon(Icons.thumb_up,
                                              recommendation.likes),
                                          _buildStatIcon(Icons.visibility,
                                              recommendation.views),
                                          _buildStatIcon(Icons.bookmark,
                                              recommendation.saved),
                                          _buildStatIcon(Icons.menu_book,
                                              recommendation.read),
                                        ],
                                      ),
                                    ],
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

                SizedBox(height: 16),
                // Рекомендоване
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFF8B6F47).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.recommend,
                          color: Color(0xFF8B6F47),
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Рекомендоване для вас',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5A4037),
                        ),
                      ),
                      Spacer(),
                      _buildActionButton(
                          Icons.filter_list, () => _showFilterDialog()),
                      SizedBox(width: 8),
                      _buildActionButton(Icons.sort, () => _showSortDialog()),
                    ],
                  ),
                ),

                SizedBox(height: 16),
                FutureBuilder<List<Recommendation>>(
                  future: recommendations,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF8B6F47)),
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Помилка: ${snapshot.error}',
                            style: TextStyle(color: Color(0xFF8B6F47)),
                          ),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.library_books,
                                size: 48,
                                color: Color(0xFFD4C4B0),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Немає доступних рекомендацій',
                                style: TextStyle(
                                  color: Color(0xFF8B6F47),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
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
                SizedBox(height: 20),
              ],
            ),
          ),
        );

      case 1:
        return IdeasPage();
      case 2:
        return SearchPage();
      case 3:
        return CreateWorkScreen();
      case 4:
        return AccountScreen(
          userId: widget.userId,
        );
      default:
        return Container(
          color: Color(0xFFF5F1EB),
          child: Center(
            child: Text(
              "Невідома сторінка",
              style: TextStyle(color: Color(0xFF8B6F47)),
            ),
          ),
        );
    }
  }

  Widget _buildActionButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFE8DDD4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, size: 18, color: Color(0xFF6B4E3D)),
        onPressed: onPressed,
        padding: EdgeInsets.all(8),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Colors.white,
          ),
          child: FilterDialog(
            selectedFilter: selectedFilter,
            onFilterSelected: (filter) {
              setState(() {
                selectedFilter = filter;
              });
            },
          ),
        );
      },
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Виберіть сортування',
            style: TextStyle(
              color: Color(0xFF5A4037),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildSortOption(
                    'За популярністю', 'popular', Icons.trending_up),
                _buildSortOption('За датою', 'date', Icons.calendar_today),
                _buildSortOption('Без сортування', null, Icons.clear),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String title, String? value, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: selectedSort == value
            ? Color(0xFF8B6F47).withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF8B6F47)),
        title: Text(
          title,
          style: TextStyle(
            color: Color(0xFF5A4037),
            fontWeight:
                selectedSort == value ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: selectedSort == value
            ? Icon(Icons.check, color: Color(0xFF8B6F47))
            : null,
        onTap: () {
          setState(() {
            selectedSort = value;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F1EB),
      appBar: AppBar(
        backgroundColor: Color(0xFFE8DDD4),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.1),
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 32,
            ),
            SizedBox(width: 10),
            Text(
              _getTitle(),
              style: TextStyle(
                color: Color(0xFF5A4037),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          _buildAppBarButton(Icons.history, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HistoryScreen(userId: widget.userId),
              ),
            );
          }),
          _buildAppBarButton(Icons.notifications, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationsScreen()),
            );
          }),
          if (_selectedIndex == 4)
            _buildAppBarButton(Icons.account_circle, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(userId: widget.userId),
                ),
              );
            }),
        ],
        leading: openedWork != null
            ? Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Color(0xFF6B4E3D)),
                  onPressed: () {
                    setState(() {
                      openedWork = null;
                    });
                  },
                ),
              )
            : null,
      ),
      body: openedWork != null
          ? WorkDetailScreen(work: openedWork!, workId: openedWork!.id)
          : _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            openedWork = null;
            _onItemTapped(index);
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF8B6F47),
        unselectedItemColor: Color(0xFFB8956F),
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
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

  Widget _buildAppBarButton(IconData icon, VoidCallback onPressed) {
    return Container(
      margin: EdgeInsets.only(right: 8, top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Color(0xFF6B4E3D)),
        onPressed: onPressed,
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
