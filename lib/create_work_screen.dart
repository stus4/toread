import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateWorkScreen extends StatefulWidget {
  @override
  _CreateWorkScreenState createState() => _CreateWorkScreenState();
}

class _CreateWorkScreenState extends State<CreateWorkScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  String status = 'Завершений';
  String ageLimit = '13+';
  List<String> genres = [];
  List<String> tags = [];
  File? coverImage;

  final TextEditingController genreController = TextEditingController();
  final TextEditingController tagController = TextEditingController();

  Future<void> pickCoverImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        coverImage = File(pickedFile.path);
      });
    }
  }

  void addGenre(String genre) {
    if (genre.isNotEmpty && !genres.contains(genre)) {
      setState(() {
        genres.add(genre);
        genreController.clear();
      });
    }
  }

  void addTag(String tag) {
    if (tag.isNotEmpty && !tags.contains(tag)) {
      setState(() {
        tags.add(tag);
        tagController.clear();
      });
    }
  }

  void submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // TODO: Надіслати дані на сервер
      print("Назва: $title");
      print("Опис: $description");
      print("Жанри: $genres");
      print("Теги: $tags");
      print("Статус: $status");
      print("Обмеження: $ageLimit");
      print("Обкладинка: ${coverImage?.path}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Новий твір')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Назва'),
                onSaved: (value) => title = value ?? '',
                validator: (value) => value!.isEmpty ? 'Введіть назву' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(labelText: 'Опис'),
                maxLines: 3,
                onSaved: (value) => description = value ?? '',
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  coverImage != null
                      ? Image.file(coverImage!,
                          width: 100, height: 100, fit: BoxFit.cover)
                      : Container(
                          width: 100, height: 100, color: Colors.grey[300]),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: pickCoverImage,
                    child: Text('Завантажити обкладинку'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text('Жанр'),
              Wrap(
                spacing: 8,
                children: genres.map((g) => Chip(label: Text(g))).toList(),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: genreController,
                      decoration: InputDecoration(hintText: 'Доданий жанр'),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                      onPressed: () => addGenre(genreController.text),
                      child: Text('+ Додати')),
                ],
              ),
              SizedBox(height: 20),
              Text('Теги'),
              Wrap(
                spacing: 8,
                children: tags.map((t) => Chip(label: Text(t))).toList(),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: tagController,
                      decoration: InputDecoration(hintText: 'Доданий тег'),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                      onPressed: () => addTag(tagController.text),
                      child: Text('+ Додати')),
                ],
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: status,
                items: ['Завершений', 'В процесі']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() => status = val!),
                decoration: InputDecoration(labelText: 'Статус'),
              ),
              DropdownButtonFormField<String>(
                value: ageLimit,
                items: ['0+', '7+', '13+', '16+', '18+']
                    .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                    .toList(),
                onChanged: (val) => setState(() => ageLimit = val!),
                decoration: InputDecoration(labelText: 'Вікові обмеження'),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: submit,
                icon: Icon(Icons.arrow_forward),
                label: Text('Продовжити'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // Створення — 4й пункт (починається з 0)
        onTap: (index) {
          // TODO: Навігація
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}
