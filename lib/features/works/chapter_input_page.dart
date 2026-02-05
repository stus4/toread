import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home_screen.dart';
import 'drafts.dart';
import '../../config.dart';

class ChapterInputPage extends StatefulWidget {
  final String workId;
  const ChapterInputPage({super.key, required this.workId});

  @override
  ChapterInputPageState createState() => ChapterInputPageState();
}

class ChapterInputPageState extends State<ChapterInputPage> {
  final TextEditingController _chapterController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  void _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'doc', 'docx', 'rtf'],
    );

    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;
      try {
        final fileContent = await File(filePath).readAsString();
        setState(() {
          _chapterController.text = fileContent;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Помилка читання файлу: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Вибір файлу скасовано')),
      );
    }
  }

  void _publish() async {
    final text = _chapterController.text.trim();
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Введіть назву розділу')),
      );
      return;
    }

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Текст першого розділу порожній')),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final user_id = prefs.getString('user_id');
    try {
      final uri = Uri.parse('$baseUrl/chapters/').replace(
        queryParameters: {
          'user_id': user_id,
        },
      );

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "work_id": widget.workId,
          "title": title,
          "content": text,
          "num": 1, // або видаляєш, якщо модель вже не вимагає
        }),
      );

      print('Status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Твір опубліковано!')),
        );

        // Затримка, щоб SnackBar встиг показатися (опціонально)
        await Future.delayed(Duration(milliseconds: 500));

        // Переходимо на HomeScreen, замінюючи поточну сторінку
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(userId: user_id!)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Помилка при публікації: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка з’єднання: $e')),
      );
    }
  }

  void _saveDraftLocally() async {
    final title = _titleController.text.trim();
    final text = _chapterController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Немає тексту для збереження')),
      );
      return;
    }

    await LocalDraftStorage.saveDraft(widget.workId, title, text);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Чернетку збережено локально')),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  void _loadDraft() async {
    final draft = await LocalDraftStorage.loadDraft(widget.workId);
    _titleController.text = draft['title']!;
    _chapterController.text = draft['text']!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EB), // М'який бежевий фон
      appBar: AppBar(
        title: const Text(
          'Введіть текст розділу',
          style: TextStyle(
            color: Color(0xFF4A3B2A), // Темно-коричневий текст
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFFE8DDD4), // Світлий бежевий
        elevation: 0,
        iconTheme: const IconThemeData(
            color: Color(0xFF6B5B47)), // Коричневий для іконок
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF5F1EB), // Світлий бежевий
              const Color(0xFFEDE6DC), // Трохи темніший бежевий
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Кнопка завантаження файлу
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B7355).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _uploadFile,
                  icon: const Icon(Icons.file_upload, color: Color(0xFFF5F1EB)),
                  label: const Text(
                    'Завантажити з файлу',
                    style: TextStyle(
                      color: Color(0xFFF5F1EB),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF8B7355), // Теплий коричневий
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Поле назви розділу
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B7355).withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _titleController,
                  style: const TextStyle(
                    color: Color(0xFF4A3B2A),
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFFAF7F2), // Дуже світлий бежевий
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF8B7355),
                        width: 2,
                      ),
                    ),
                    hintText: 'Введіть назву розділу',
                    hintStyle: const TextStyle(
                      color: Color(0xFF9B8B7A),
                      fontSize: 16,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    prefixIcon: const Icon(
                      Icons.title,
                      color: Color(0xFF8B7355),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Поле тексту розділу
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B7355).withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _chapterController,
                    maxLines: null,
                    expands: true,
                    style: const TextStyle(
                      color: Color(0xFF4A3B2A),
                      fontSize: 16,
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFFAF7F2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF8B7355),
                          width: 2,
                        ),
                      ),
                      hintText: 'Введіть текст розділу тут...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF9B8B7A),
                        fontSize: 16,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                      alignLabelWithHint: true,
                    ),
                    textAlignVertical: TextAlignVertical.top,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Кнопки дій
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B7355).withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _saveDraftLocally,
                        icon: const Icon(Icons.save_outlined,
                            color: Color(0xFF8B7355)),
                        label: const Text(
                          'Зберегти чернетку',
                          style: TextStyle(
                            color: Color(0xFF8B7355),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFAF7F2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: Color(0xFF8B7355),
                              width: 1.5,
                            ),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6B5B47).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _publish,
                        icon:
                            const Icon(Icons.publish, color: Color(0xFFFAF7F2)),
                        label: const Text(
                          'Опублікувати',
                          style: TextStyle(
                            color: Color(0xFFFAF7F2),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF6B5B47), // Темний коричневий
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
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
  }
}
