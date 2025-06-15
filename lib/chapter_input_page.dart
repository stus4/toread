import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'drafts.dart';
import 'config.dart';

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
      appBar: AppBar(title: Text('Введіть текст розділу')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
                onPressed: _uploadFile, child: Text('Завантажити з файлу')),
            SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Введіть назву розділу',
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: TextField(
                controller: _chapterController,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Введіть текст розділу тут...',
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                      onPressed: _saveDraftLocally,
                      child: Text('Зберегти чернетку')),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                      onPressed: _publish, child: Text('Опублікувати')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
