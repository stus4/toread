import 'package:flutter/material.dart';
import '../../core/styles/colors.dart';

class IdeasPage extends StatefulWidget {
  @override
  _IdeasPageState createState() => _IdeasPageState();
}

class _IdeasPageState extends State<IdeasPage> {
  List<Map<String, dynamic>> ideas = [
    {
      'title': 'Вбивця головний герой',
      'author': 'Оксана',
      'genre': 'Детктив',
      'tags': 'Ненадійний оповідач',
      'description': 'Твір, де в кінці виявиться що головний герой вбивця',
    },
    {
      'title': 'Магічний реалізм',
      'author': 'jfy',
      'genre': 'Фентезі',
      'tags': '',
      'description':
          'У маленькому провінційному містечку раптом починають зникати тіні людей. Головний герой, простий поштар, розслідує цю загадку і відкриває, що тіні — це ключі до паралельного світу, де живуть забуті спогади.',
      'hasCode': true,
    },
    {
      'title': 'Постапокаліпсис',
      'author': 'oksana',
      'genre': '',
      'tags': '',
      'description':
          'Після катастрофи, що зруйнувала більшість міст, невелика група виживших живе у підземному метро. Вони намагаються відновити цивілізацію, борючись із мутантами і власними страхами.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F2E8),
      appBar: AppBar(
        title: Text(
          "",
          style: TextStyle(
            color: Color(0xFF8B4513),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Color(0xFFE8DCC0),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF8B4513)),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.filter_list, color: Color(0xFF8B4513)),
              onPressed: () {},
              tooltip: "Фільтри",
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.sort, color: Color(0xFF8B4513)),
              onPressed: () {},
              tooltip: "Сортування",
            ),
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
                return _buildIdeaCard(ideas[index], index);
              },
            ),
          ),

          // Floating Add Button Area
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF5F2E8).withOpacity(0),
                  Color(0xFFF5F2E8),
                ],
              ),
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF8B4513),
                      Color(0xFFA0522D),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF8B4513).withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showAddIdeaDialog();
                  },
                  icon: Icon(Icons.add, size: 20, color: Colors.white),
                  label: Text(
                    'Додати ідею',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdeaCard(Map<String, dynamic> idea, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF8B4513).withOpacity(0.1),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFE8DCC0),
                    Color(0xFFF0ECE8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          idea['title'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8B4513),
                          ),
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFF8B4513).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          idea['author'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF8B4513),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 16,
                        color: Color(0xFF8B4513).withOpacity(0.7),
                      ),
                      SizedBox(width: 4),
                      Text(
                        idea['genre'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8B4513).withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags
                  if (idea['tags'].toString().isNotEmpty) ...[
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: idea['tags']
                          .toString()
                          .split(',')
                          .map((tag) => Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFFE8DCC0),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Color(0xFF8B4513).withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  tag.trim(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF8B4513),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    SizedBox(height: 12),
                  ],

                  // Description
                  Text(
                    idea['description'],
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Action Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF8B4513).withOpacity(0.8),
                            Color(0xFFA0522D).withOpacity(0.8),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF8B4513).withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          print('Написати за ідеєю: ${idea['title']}');
                        },
                        icon: Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Написати',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Color(0xFFF5F2E8),
                ],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFF8B4513).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.lightbulb_outline,
                            color: Color(0xFF8B4513),
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Додати нову ідею',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8B4513),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Form
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildStyledTextField(
                            titleController, 'Назва', Icons.title),
                        SizedBox(height: 16),
                        _buildStyledTextField(
                            authorController, 'Автор', Icons.person_outline),
                        SizedBox(height: 16),
                        _buildStyledTextField(
                            genreController, 'Жанр', Icons.category_outlined),
                        SizedBox(height: 16),
                        _buildStyledTextField(
                            tagsController, 'Теги', Icons.tag),
                        SizedBox(height: 16),
                        _buildStyledTextField(
                          descriptionController,
                          'Опис',
                          Icons.description_outlined,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Color(0xFF8B4513).withOpacity(0.7),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        child: Text(
                          'Скасувати',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF8B4513),
                              Color(0xFFA0522D),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF8B4513).withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
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
                                  'description':
                                      descriptionController.text.isEmpty
                                          ? 'опис'
                                          : descriptionController.text,
                                });
                              });
                              Navigator.of(context).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: Text(
                            'Додати',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildStyledTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF8B4513).withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Color(0xFF8B4513).withOpacity(0.7)),
          prefixIcon: Icon(icon, color: Color(0xFF8B4513).withOpacity(0.7)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF8B4513), width: 2),
          ),
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: IdeasPage(),
  ));
}
