import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'editwork.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({required this.userId, super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final response =
        await http.get(Uri.parse('$baseUrl/users/${widget.userId}'));

    if (response.statusCode == 200) {
      setState(() {
        userData = json.decode(response.body);
      });
    } else {
      print('Помилка при завантаженні даних профілю');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              // перехід до сторінки налаштувань
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Налаштування')));
            },
          )
        ],
      ),
      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Profile Header
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Аватар
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey[300],
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userData!['username'],
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  userData!['description'] ?? 'Опис відсутній',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // перехід до редагування профілю
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Редагувати профіль')));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('Редагувати'),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Статистика
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn(
                              userData!['followers'].toString(), 'Підписників'),
                          _buildStatColumn(userData!['following'].toString(),
                              'Відстежується'),
                          _buildStatColumn(
                              userData!['works_count'].toString(), 'Твори'),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                // Заголовок
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Твори автора',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Icon(Icons.filter_list, size: 20),
                          SizedBox(width: 10),
                          Icon(Icons.sort, size: 20),
                        ],
                      ),
                    ],
                  ),
                ),
                // Список творів (заглушка)
                Expanded(
                  child: ListView.builder(
                    itemCount: userData!['works']?.length ?? 0,
                    itemBuilder: (context, index) {
                      final work = userData!['works'][index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditWorkPage(work: work),
                            ),
                          );
                        },
                        child: _buildWorkItem(work),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatColumn(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildWorkItem(dynamic work) {
    final title = work['title'] ?? 'Без назви';
    final genre = work['category'] ?? 'Жанр не вказано';
    final tags = (work['tags'] as List<dynamic>?)?.join(', ') ?? 'Без тегів';
    final description = work['short_description'] ?? 'Опис відсутній';

    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 1),
      padding: EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
              // Можеш додати тут backgroundImage якщо в тебе є шлях до обкладинки
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(genre,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                SizedBox(height: 4),
                Text(tags,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
