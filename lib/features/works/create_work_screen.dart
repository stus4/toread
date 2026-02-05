import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'chapter_input_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config.dart';

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
        http.get(Uri.parse('$baseUrl/categories')),
        http.get(Uri.parse('$baseUrl/tags')),
        http.get(Uri.parse('$baseUrl/work-statuses')),
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
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void updateSelectedTags(Set<String> newSelectedTags) {
    setState(() {
      selectedTagIds.clear();
      selectedTagIds.addAll(newSelectedTags);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F2E8), // світло-бежевий фон
      appBar: AppBar(
        title: Text(
          "Створити твір",
          style: TextStyle(
            color: Color(0xFF8B4513),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Color(0xFFE8DCC0),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF8B4513)),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B4513)),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Основна інформація
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          "Основна інформація",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8B4513),
                          ),
                        ),
                      ),

                      // Назва твору
                      Container(
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF8B4513).withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: "Назва твору",
                            labelStyle: TextStyle(color: Color(0xFF8B4513)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.all(16),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Color(0xFF8B4513), width: 2),
                            ),
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? "Введіть назву"
                              : null,
                        ),
                      ),

                      // Опис
                      Container(
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF8B4513).withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _descriptionController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: "Опис",
                            labelStyle: TextStyle(color: Color(0xFF8B4513)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.all(16),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Color(0xFF8B4513), width: 2),
                            ),
                          ),
                        ),
                      ),

                      // Розділювач
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 16),
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Color(0xFF8B4513).withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),

                      // Жанр
                      Container(
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF8B4513).withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "Жанр",
                            labelStyle: TextStyle(color: Color(0xFF8B4513)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.all(16),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Color(0xFF8B4513), width: 2),
                            ),
                          ),
                          value: selectedCategory,
                          dropdownColor: Color(0xFFF5F2E8),
                          items: categories
                              .map((cat) => DropdownMenuItem<String>(
                                    value: cat['id'].toString(),
                                    child: Text(
                                      cat['name'],
                                      style:
                                          TextStyle(color: Color(0xFF8B4513)),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => selectedCategory = value),
                          validator: (value) =>
                              value == null ? 'Оберіть жанр' : null,
                        ),
                      ),

                      // Статус
                      Container(
                        margin: EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF8B4513).withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "Статус",
                            labelStyle: TextStyle(color: Color(0xFF8B4513)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.all(16),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Color(0xFF8B4513), width: 2),
                            ),
                          ),
                          value: selectedStatus,
                          dropdownColor: Color(0xFFF5F2E8),
                          items: statuses
                              .where((status) => status['id'].toString() != '4')
                              .map((status) => DropdownMenuItem<String>(
                                    value: status['id'].toString(),
                                    child: Text(
                                      status['name'],
                                      style:
                                          TextStyle(color: Color(0xFF8B4513)),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => selectedStatus = value),
                          validator: (value) =>
                              value == null ? 'Оберіть статус' : null,
                        ),
                      ),

                      // Теги
                      Container(
                        margin: EdgeInsets.only(bottom: 32),
                        child: TagSelector(
                          tags: tags,
                          selectedTags: selectedTagIds,
                          onSelectionChanged: updateSelectedTags,
                        ),
                      ),

                      // Кнопка продовження
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
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
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final authorId = prefs.getString('user_id');

                              final newWorkData = {
                                'title': _titleController.text,
                                'description': _descriptionController.text,
                                'category_id': selectedCategory,
                                'status_id': selectedStatus,
                                'tag_ids': selectedTagIds.toList(),
                                'author_id': authorId,
                              };

                              try {
                                final response = await http.post(
                                  Uri.parse('$baseUrl/works/'),
                                  headers: {'Content-Type': 'application/json'},
                                  body: jsonEncode(newWorkData),
                                );

                                if (response.statusCode == 201 ||
                                    response.statusCode == 200) {
                                  final responseData =
                                      jsonDecode(response.body);
                                  final createdWorkId =
                                      responseData['id'].toString();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChapterInputPage(
                                          workId: createdWorkId),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Не вдалося створити твір"),
                                      backgroundColor: Color(0xFF8B4513),
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Помилка: $e"),
                                    backgroundColor: Color(0xFF8B4513),
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            "Продовжити",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class TagSelector extends StatefulWidget {
  final List<Map<String, dynamic>> tags;
  final Set<String> selectedTags;
  final ValueChanged<Set<String>> onSelectionChanged;

  const TagSelector({
    super.key,
    required this.tags,
    required this.selectedTags,
    required this.onSelectionChanged,
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onTagSelected(String tagId, bool selected) {
    final newSelected = Set<String>.from(widget.selectedTags);
    if (selected) {
      newSelected.add(tagId);
    } else {
      newSelected.remove(tagId);
    }
    widget.onSelectionChanged(newSelected);
  }

  @override
  Widget build(BuildContext context) {
    final selectedTagList = widget.tags.where(
      (tag) => widget.selectedTags.contains(tag['id'].toString()),
    );

    final filteredTagList = _searchText.isEmpty
        ? []
        : widget.tags.where((tag) {
            final tagId = tag['id'].toString();
            final tagName = tag['name'].toString().toLowerCase();
            return tagName.contains(_searchText) &&
                !widget.selectedTags.contains(tagId);
          }).toList();

    return Container(
      padding: EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Теги",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8B4513),
            ),
          ),
          SizedBox(height: 16),

          // Поле пошуку
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFF5F2E8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Пошук тегів",
                labelStyle:
                    TextStyle(color: Color(0xFF8B4513).withOpacity(0.7)),
                prefixIcon: Icon(Icons.search, color: Color(0xFF8B4513)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Color(0xFFF5F2E8),
                contentPadding: EdgeInsets.all(16),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF8B4513), width: 2),
                ),
              ),
            ),
          ),
          SizedBox(height: 16),

          // Вибрані теги
          if (widget.selectedTags.isNotEmpty) ...[
            Text(
              "Вибрані теги:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8B4513),
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: selectedTagList.map((tag) {
                final tagId = tag['id'].toString();
                final tagName = tag['name'];
                final tagDescription = tag['description'] ?? 'Немає опису';

                return Tooltip(
                  message: tagDescription,
                  waitDuration: Duration(milliseconds: 400),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF8B4513),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF8B4513).withOpacity(0.3),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: FilterChip(
                      label: Text(
                        tagName,
                        style: TextStyle(color: Colors.white),
                      ),
                      selected: true,
                      backgroundColor: Colors.transparent,
                      selectedColor: Colors.transparent,
                      checkmarkColor: Colors.white,
                      onSelected: (isSelected) {
                        _onTagSelected(tagId, !isSelected);
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
          ],

          // Результати пошуку
          if (_searchText.isNotEmpty) ...[
            Text(
              "Результати пошуку:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8B4513),
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: filteredTagList.map((tag) {
                final tagId = tag['id'].toString();
                final tagName = tag['name'];
                final tagDescription = tag['description'] ?? 'Немає опису';

                return Tooltip(
                  message: tagDescription,
                  waitDuration: Duration(milliseconds: 400),
                  child: FilterChip(
                    label: Text(
                      tagName,
                      style: TextStyle(color: Color(0xFF8B4513)),
                    ),
                    selected: false,
                    backgroundColor: Color(0xFFF5F2E8),
                    selectedColor: Color(0xFF8B4513).withOpacity(0.2),
                    checkmarkColor: Color(0xFF8B4513),
                    onSelected: (isSelected) {
                      _onTagSelected(tagId, true);
                      _searchController.clear();
                    },
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
