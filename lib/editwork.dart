import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';

class EditWorkPage extends StatefulWidget {
  final Map<String, dynamic> work;

  const EditWorkPage({super.key, required this.work});

  @override
  State<EditWorkPage> createState() => _EditWorkPageState();
}

class _EditWorkPageState extends State<EditWorkPage> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController tagsController;

  List<Map<String, dynamic>> categories = [];
  int? selectedCategoryId;
  List<dynamic> chapters = [];

  @override
  void initState() {
    super.initState();

    // Ініціалізуємо контролери з даних твору
    titleController = TextEditingController(text: widget.work['title'] ?? '');
    descriptionController =
        TextEditingController(text: widget.work['description'] ?? '');

    // Теги з List<dynamic>? перетворюємо у рядок через кому
    final tagsList = widget.work['tags'] as List<dynamic>?;
    tagsController = TextEditingController(text: tagsList?.join(', ') ?? '');

    // Обробка категорії
    selectedCategoryId = null;
    final category = widget.work['category'];
    if (category != null && category is Map) {
      final catId = category['id'];
      if (catId is int) {
        selectedCategoryId = catId;
      } else if (catId is String) {
        selectedCategoryId = int.tryParse(catId);
      }
    }

    // Розділи твору
    chapters = widget.work['chapters'] ?? [];

    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final url = Uri.parse('$baseUrl/categories');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          categories = data
              .map<Map<String, dynamic>>((cat) {
                final idRaw = cat['id'];
                int? idParsed;
                if (idRaw is int) {
                  idParsed = idRaw;
                } else if (idRaw is String) {
                  idParsed = int.tryParse(idRaw);
                }

                return {
                  'id': idParsed ?? 0,
                  'name': cat['name'] ?? 'Без назви',
                  'description': cat['description'] ?? '',
                };
              })
              .where((cat) => cat['id'] != 0)
              .toList();
        });
      } else {
        print('Помилка завантаження категорій: статус ${response.statusCode}');
      }
    } catch (e) {
      print('Помилка завантаження категорій: $e');
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    tagsController.dispose();
    super.dispose();
  }

  void saveChanges() async {
    final url = Uri.parse('$baseUrl/works/${widget.work['id']}');

    // Формуємо список тегів як List<String>
    final tagsList = tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final body = json.encode({
      'title': titleController.text,
      'description': descriptionController.text,
      'category_id': selectedCategoryId,
      'tags': tagsList,
    });

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Зміни збережено')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Помилка збереження: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка: $e')),
      );
    }
  }

  void addChapter() {
    // TODO: Реалізувати перехід до створення нового розділу
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Перехід до створення розділу')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Редагування твору')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Назва твору
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Назва твору'),
            ),
            const SizedBox(height: 16),

            // Опис твору
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Опис'),
            ),
            const SizedBox(height: 16),

            // Вибір категорії
            DropdownButtonFormField<int>(
              value: selectedCategoryId,
              decoration: const InputDecoration(labelText: 'Жанр'),
              items: categories.map((category) {
                return DropdownMenuItem<int>(
                  value: category['id'] as int,
                  child: Text(category['name'] as String),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedCategoryId = value),
            ),
            const SizedBox(height: 16),

            // Теги
            TextField(
              controller: tagsController,
              decoration: const InputDecoration(
                  labelText: 'Теги (через кому, без "#")'),
            ),
            const SizedBox(height: 24),

            // Кнопка збереження
            ElevatedButton(
              onPressed: saveChanges,
              child: const Text('Зберегти'),
            ),
            const SizedBox(height: 24),

            // Кнопка додати розділ
            ElevatedButton.icon(
              onPressed: addChapter,
              icon: const Icon(Icons.add),
              label: const Text('Додати розділ'),
            ),
            const SizedBox(height: 24),

            // Список розділів
            const Text(
              'Розділи:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...chapters.map((chapter) {
              final title = chapter['title'] ?? 'Без назви';
              final number = chapter['number']?.toString() ?? '-';
              final id = chapter['id']?.toString() ?? '';
              return ListTile(
                title: Text(title),
                subtitle: Text('Номер: $number, ID: $id'),
                onTap: () {
                  // TODO: перехід до редагування розділу
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
