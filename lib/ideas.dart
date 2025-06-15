import 'package:flutter/material.dart';
import 'colors.dart';

class IdeasPage extends StatefulWidget {
  @override
  _IdeasPageState createState() => _IdeasPageState();
}

class _IdeasPageState extends State<IdeasPage> {
  List<Map<String, dynamic>> ideas = [
    {
      'title': 'назва',
      'author': 'Оксана',
      'genre': 'Романтика',
      'tags': '',
      'description':
          'опис юагато опису текст і тд всяке таке і тд тгд тгд аспміроттр',
    },
    {
      'title': 'назва',
      'author': 'jfy',
      'genre': 'Фентезі',
      'tags': '',
      'description':
          'опис юагато опису текст і тд всяке таке і тд тгд тгд аспміроттр',
      'hasCode': true,
    },
    {
      'title': 'назва',
      'author': 'oksana',
      'genre': '',
      'tags': '',
      'description':
          'опис юагато опису текст і тд всяке таке і тд тгд тгд аспміроттр',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F4F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.sort, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: ideas.length,
              itemBuilder: (context, index) {
                return _buildIdeaCard(ideas[index]);
              },
            ),
          ),
          // Add Button
          Container(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showAddIdeaDialog();
                },
                icon: Icon(Icons.add, size: 18),
                label: Text('Додати'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.backgroundColor,
                  foregroundColor: Colors.black,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdeaCard(Map<String, dynamic> idea) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF0ECE8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Author row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                idea['title'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                idea['author'],
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          // Genre
          Text(
            idea['genre'],
            style: TextStyle(
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          // Tags
          Text(
            idea['tags'],
            style: TextStyle(
              fontSize: 14,
            ),
          ),

          SizedBox(height: 8),
          // Description
          Text(
            idea['description'],
            style: TextStyle(
              fontSize: 13,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddIdeaDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController authorController = TextEditingController();
    final TextEditingController genreController = TextEditingController();
    final TextEditingController tagsController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Додати нову ідею'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Назва',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: authorController,
                  decoration: InputDecoration(
                    labelText: 'Автор',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: genreController,
                  decoration: InputDecoration(
                    labelText: 'Жанр',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: tagsController,
                  decoration: InputDecoration(
                    labelText: 'Теги',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Опис',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Скасувати'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  setState(() {
                    ideas.add({
                      'title': titleController.text,
                      'author': authorController.text.isEmpty
                          ? 'oksana'
                          : authorController.text,
                      'genre': genreController.text.isEmpty
                          ? 'жанр'
                          : genreController.text,
                      'tags': tagsController.text.isEmpty
                          ? 'теги'
                          : tagsController.text,
                      'description': descriptionController.text.isEmpty
                          ? 'опис'
                          : descriptionController.text,
                    });
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Додати'),
            ),
          ],
        );
      },
    );
  }
}

// Main App
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ideas App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: IdeasPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

void main() {
  runApp(MyApp());
}
