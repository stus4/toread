import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class ChapterInputPage extends StatefulWidget {
  const ChapterInputPage({super.key});

  @override
  ChapterInputPageState createState() => ChapterInputPageState();
}

class ChapterInputPageState extends State<ChapterInputPage> {
  final TextEditingController _chapterController = TextEditingController();

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

  void _publish() {
    final text = _chapterController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Текст першого розділу порожній')),
      );
      return;
    }
    // TODO: Додати логіку публікації твору
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Твір опубліковано!')),
    );
  }

  void _saveDraft() {
    final text = _chapterController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Немає тексту для збереження')),
      );
      return;
    }
    // TODO: Додати логіку збереження чернетки
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Чернетка збережена')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Введіть текст першого розділу'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _uploadFile,
              child: Text('Завантажити з файлу'),
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
                    onPressed: _saveDraft,
                    child: Text('Зберегти чернетку'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _publish,
                    child: Text('Опублікувати'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
