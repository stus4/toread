import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'config.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String userId;

  const EditProfilePage(
      {super.key, required this.userData, required this.userId});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController usernameController;
  late TextEditingController descriptionController;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    usernameController =
        TextEditingController(text: widget.userData['username']);
    descriptionController =
        TextEditingController(text: widget.userData['description'] ?? '');
  }

  @override
  void dispose() {
    usernameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> saveProfile() async {
    try {
      final uri = Uri.parse('$baseUrl/users/${widget.userId}');
      var request = http.MultipartRequest('PUT', uri)
        ..fields['username'] = usernameController.text
        ..fields['description'] = descriptionController.text;

      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'avatar', // це має відповідати ключу на бекенді
          _selectedImage!.path,
        ));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не вдалося зберегти зміни')),
        );
      }
    } catch (e) {
      print('Помилка: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = widget.userData['avatar']; // або null
    return Scaffold(
      appBar: AppBar(
        title: Text('Редагування профілю'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : (avatarUrl != null
                        ? NetworkImage('$baseUrl/$avatarUrl')
                        : null) as ImageProvider?,
                child: _selectedImage == null && avatarUrl == null
                    ? Icon(Icons.camera_alt, size: 40)
                    : null,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Ім’я користувача'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Опис',
                alignLabelWithHint: true,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              child: Text('Зберегти'),
            ),
          ],
        ),
      ),
    );
  }
}
