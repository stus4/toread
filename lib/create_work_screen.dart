import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'chapter_input_page.dart';

class CreateWorkScreen extends StatefulWidget {
  @override
  _CreateWorkScreenState createState() => _CreateWorkScreenState();
}

class _CreateWorkScreenState extends State<CreateWorkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? selectedCategory;
  String? selectedStatus;
  final Set<String> selectedTagIds = {};

  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> tags = [];
  List<Map<String, dynamic>> statuses = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFormData();
  }

  Future<void> loadFormData() async {
    try {
      final responses = await Future.wait([
        http.get(Uri.parse('http://192.168.1.2:8000/categories')),
        http.get(Uri.parse('http://192.168.1.2:8000/tags')),
        http.get(Uri.parse('http://192.168.1.2:8000/work-statuses')),
      ]);

      if (responses.every((res) => res.statusCode == 200)) {
        setState(() {
          categories = List<Map<String, dynamic>>.from(
              json.decode(utf8.decode(responses[0].bodyBytes)));
          tags = List<Map<String, dynamic>>.from(
              json.decode(utf8.decode(responses[1].bodyBytes)));
          statuses = List<Map<String, dynamic>>.from(
              json.decode(utf8.decode(responses[2].bodyBytes)));
          isLoading = false;
        });
      } else {
        throw Exception("Не вдалося завантажити дані");
      }
    } catch (e) {
      print("Помилка: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Помилка завантаження даних")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Створити твір")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: "Назва твору"),
                      validator: (value) => (value == null || value.isEmpty)
                          ? "Введіть назву"
                          : null,
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: "Опис"),
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: "Жанр"),
                      value: selectedCategory,
                      items: categories
                          .map((cat) => DropdownMenuItem<String>(
                                value: cat['id'].toString(),
                                child: Text(cat['name']),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedCategory = value),
                      validator: (value) =>
                          value == null ? 'Оберіть жанр' : null,
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: "Статус"),
                      value: selectedStatus,
                      items: statuses
                          .where((status) =>
                              status['id'].toString() != '4') // фільтруємо
                          .map((status) => DropdownMenuItem<String>(
                                value: status['id'].toString(),
                                child: Text(status['name']),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedStatus = value),
                      validator: (value) =>
                          value == null ? 'Оберіть статус' : null,
                    ),
                    SizedBox(height: 16),
                    TagSelector(tags: tags, selectedTags: selectedTagIds),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChapterInputPage()),
                          );
                        }
                      },
                      child: Text("Продовжити"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class TagSelector extends StatefulWidget {
  final List<Map<String, dynamic>> tags;
  final Set<String> selectedTags;

  const TagSelector({
    super.key,
    required this.tags,
    required this.selectedTags,
  });

  @override
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Теги, які вибрані
    final selectedTagList = widget.tags.where(
      (tag) => widget.selectedTags.contains(tag['id'].toString()),
    );

    // Теги, які збігаються з пошуком, але ще не вибрані
    final filteredTagList = _searchText.isEmpty
        ? []
        : widget.tags.where((tag) {
            final tagId = tag['id'].toString();
            final tagName = tag['name'].toString().toLowerCase();
            return tagName.contains(_searchText) &&
                !widget.selectedTags.contains(tagId);
          }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: "Пошук тегів",
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        // Вибрані теги
        if (widget.selectedTags.isNotEmpty) ...[
          Text("Вибрані теги:"),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8.0,
            children: selectedTagList.map((tag) {
              final tagId = tag['id'].toString();
              final tagName = tag['name'];
              final tagDescription = tag['description'] ?? 'Немає опису';

              return Tooltip(
                message: tagDescription,
                waitDuration: Duration(milliseconds: 400),
                child: FilterChip(
                  label: Text(tagName),
                  selected: true,
                  onSelected: (isSelected) {
                    setState(() {
                      widget.selectedTags.remove(tagId);
                    });
                  },
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],

        // Пошук
        if (_searchText.isNotEmpty) ...[
          Text("Результати пошуку:"),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8.0,
            children: filteredTagList.map((tag) {
              final tagId = tag['id'].toString();
              final tagName = tag['name'];
              final tagDescription = tag['description'] ?? 'Немає опису';

              return Tooltip(
                message: tagDescription,
                waitDuration: Duration(milliseconds: 400),
                child: FilterChip(
                  label: Text(tagName),
                  selected: widget.selectedTags.contains(tagId),
                  onSelected: (isSelected) {
                    setState(() {
                      if (isSelected) {
                        widget.selectedTags.add(tagId);
                      } else {
                        widget.selectedTags.remove(tagId);
                      }
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ]
      ],
    );
  }
}
