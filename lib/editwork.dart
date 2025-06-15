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
  TextEditingController? coverPathController;

  TextEditingController? filePathController;
  TextEditingController? ageLimitController;
  int? selectedStatusId;

  List<Map<String, dynamic>> categories = [];
  int? selectedCategoryId;
  List<dynamic> chapters = [];

  bool isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.work['title'] ?? '');
    descriptionController =
        TextEditingController(text: widget.work['description'] ?? '');
    coverPathController =
        TextEditingController(text: widget.work['cover_path'] ?? '');
    filePathController =
        TextEditingController(text: widget.work['file_path'] ?? '');
    ageLimitController = TextEditingController(
        text: widget.work['age_limit']?.toString() ?? '0');

    // Безпечна ініціалізація selectedStatusId
    selectedStatusId = null;
    final status = widget.work['status'];
    if (status != null && status is Map) {
      final statusIdRaw = status['id'];
      if (statusIdRaw is int) {
        selectedStatusId = statusIdRaw;
      } else if (statusIdRaw is String) {
        selectedStatusId = int.tryParse(statusIdRaw);
      }
    }

    // Безпечна ініціалізація selectedCategoryId
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

    final tagsList = widget.work['tags'] as List<dynamic>?;
    tagsController = TextEditingController(text: tagsList?.join(', ') ?? '');

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
          // Якщо selectedCategoryId не null, перевіряємо чи є він в categories
          if (selectedCategoryId != null &&
              !categories.any((cat) => cat['id'] == selectedCategoryId)) {
            selectedCategoryId = null; // або можна вибрати перший елемент
          }

          isLoadingCategories = false;
        });
      } else {
        print('Помилка завантаження категорій: статус ${response.statusCode}');
        setState(() {
          isLoadingCategories = false;
        });
      }
    } catch (e) {
      print('Помилка завантаження категорій: $e');
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController?.dispose();
    tagsController?.dispose();
    coverPathController?.dispose();

    filePathController?.dispose();
    ageLimitController?.dispose();

    super.dispose();
  }

  void saveChanges() async {
    final url = Uri.parse('$baseUrl/works/${widget.work['id']}');

    // Припускаємо, що ці контролери/змінні вже є або будуть:
    final coverPath = coverPathController?.text ?? '';
// або як ти зберігаєш шлях
    final filePath = filePathController?.text ?? '';
    final ageLimit = int.tryParse(ageLimitController?.text ?? '') ?? 0;

    final statusId = selectedStatusId; // має бути int

    // Формуємо список тегів як List<String> UUID
    final tagsList = tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) =>
            RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(tag)) // залишаємо лише UUID
        .toList();

    final body = json.encode({
      'title': titleController.text,
      'description': descriptionController.text,
      'cover_path': coverPath?.isNotEmpty == true ? coverPath : null,
      'file_path': filePath,
      'category_id': selectedCategoryId,
      'tags': tagsList,
      'age_limit': ageLimit,
      'status_id': statusId,
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
// Обкладинка
            TextField(
              controller: coverPathController,
              decoration:
                  const InputDecoration(labelText: 'Шлях до обкладинки'),
            ),
            const SizedBox(height: 16),

// Файл з розділами
            TextField(
              controller: filePathController,
              decoration: const InputDecoration(labelText: 'Шлях до файлу'),
            ),
            const SizedBox(height: 16),

// Вікове обмеження
            TextField(
              controller: ageLimitController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Вікове обмеження'),
            ),
            const SizedBox(height: 16),

// Статус твору
            DropdownButtonFormField<int>(
              value: selectedStatusId,
              decoration: const InputDecoration(labelText: 'Статус твору'),
              items: const [
                DropdownMenuItem(value: 1, child: Text('У процесі')),
                DropdownMenuItem(value: 2, child: Text('Завершено')),
                // Додай за потребою більше
              ],
              onChanged: (value) => setState(() => selectedStatusId = value),
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
