import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config.dart';
import '../../models/recommendation.dart';

import 'tabs/notifications_screen.dart';
import 'home_body.dart';
import 'recommendation_card.dart';
import '../filters/filter_sort_dialogs.dart';

import '../works/create_work_screen.dart';
import '../works/search.dart';
import '../works/ideas.dart';
import '../works/work_detail_screen.dart';
import '../profile/account_screen.dart';
import '../profile/profile_screen.dart';
import 'history_screen.dart';

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
  String? selectedFilter;
  String? selectedSort;

  @override
  void initState() {
    super.initState();
    recommendations = fetchRecommendations(widget.userId);
    popularWorks = fetchPopularWorks();
  }

  // ================= API =================
  Future<List<Recommendation>> fetchRecommendations(String userId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/recommendations/$userId'));

    if (response.statusCode == 200) {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      if (decoded is List) {
        return decoded.map((e) => Recommendation.fromJson(e)).toList();
      } else if (decoded is Map && decoded['recommendations'] != null) {
        return (decoded['recommendations'] as List)
            .map((e) => Recommendation.fromJson(e))
            .toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Не вдалося завантажити рекомендації');
    }
  }

  Future<List<Recommendation>> fetchPopularWorks() async {
    final response = await http.get(Uri.parse('$baseUrl/popular'));
    if (response.statusCode == 200) {
      return (json.decode(utf8.decode(response.bodyBytes)) as List)
          .map((e) => Recommendation.fromJson(e))
          .toList();
    } else {
      throw Exception('Не вдалося завантажити популярні твори');
    }
  }

  // ================= BottomNavigation =================
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      openedWork = null;
    });
  }

  // ================= AppBar Buttons =================
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
              offset: Offset(0, 2))
        ],
      ),
      child: IconButton(
          icon: Icon(icon, color: Color(0xFF6B4E3D)), onPressed: onPressed),
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => FilterDialog(
        selectedFilter: selectedFilter,
        onFilterSelected: (filter) => setState(() => selectedFilter = filter),
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => SortDialog(
        selectedSort: selectedSort,
        onSortSelected: (sort) => setState(() => selectedSort = sort),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return FutureBuilder<List<Recommendation>>(
          future: recommendations, // твоє fetchRecommendations(widget.userId)
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Помилка: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Немає рекомендацій'));
            } else {
              // передаємо готовий список у HomeBody
              return HomeBody(
                recommendations: snapshot.data!,
                popularWorks: [], // пізніше теж можна зробити FutureBuilder
                onOpenWork: (work) => setState(() => openedWork = work),
                onFilter: _showFilterDialog,
                onSort: _showSortDialog,
              );
            }
          },
        );
      case 1:
        return IdeasPage();
      case 2:
        return SearchPage();
      case 3:
        return CreateWorkScreen();
      case 4:
        return AccountScreen(userId: widget.userId);
      default:
        return Center(child: Text("Невідома сторінка"));
    }
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
            Image.asset('assets/logo.png', height: 32),
            SizedBox(width: 10),
            Text(_getTitle(),
                style: TextStyle(
                    color: Color(0xFF5A4037), fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          _buildAppBarButton(Icons.history, () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => HistoryScreen(userId: widget.userId)));
          }),
          _buildAppBarButton(Icons.notifications, () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => NotificationsScreen()));
          }),
          if (_selectedIndex == 4)
            _buildAppBarButton(Icons.account_circle, () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ProfilePage(userId: widget.userId)));
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
                        offset: Offset(0, 2))
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Color(0xFF6B4E3D)),
                  onPressed: () => setState(() => openedWork = null),
                ),
              )
            : null,
      ),
      body: openedWork != null
          ? WorkDetailScreen(work: openedWork!, workId: openedWork!.id)
          : _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF8B6F47),
        unselectedItemColor: Color(0xFFB8956F),
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Головна'),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: 'Ідеї'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Пошук'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Написати'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Акаунт'),
        ],
      ),
    );
  }
}
