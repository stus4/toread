import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FilterDialog extends StatefulWidget {
  final String? selectedFilter;
  final Function(String?) onFilterSelected;

  const FilterDialog({
    Key? key,
    required this.selectedFilter,
    required this.onFilterSelected,
  }) : super(key: key);

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> tags = [];
  List<Map<String, dynamic>> statuses = [];

  bool isLoading = true;
  String? error;

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
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Помилка завантаження даних")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return AlertDialog(
        title: Text('Завантаження фільтрів...'),
        content: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return AlertDialog(
        title: Text('Помилка'),
        content: Text(error!),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Закрити'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: Text('Виберіть фільтр'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Категорії:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...categories.map((cat) => ListTile(
                  title: Text(cat['name']),
                  selected: widget.selectedFilter == cat['name'],
                  onTap: () {
                    widget.onFilterSelected(cat['name']);
                    Navigator.pop(context);
                  },
                )),
            Divider(),
            Text('Теги:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...tags.map((tag) => ListTile(
                  title: Text(tag['name']),
                  selected: widget.selectedFilter == tag['name'],
                  onTap: () {
                    widget.onFilterSelected(tag['name']);
                    Navigator.pop(context);
                  },
                )),
            Divider(),
            Text('Статуси творів:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...statuses.map((status) => ListTile(
                  title: Text(status['name']),
                  selected: widget.selectedFilter == status['name'],
                  onTap: () {
                    widget.onFilterSelected(status['name']);
                    Navigator.pop(context);
                  },
                )),
            Divider(),
            ListTile(
              title: Text('Без фільтра'),
              selected: widget.selectedFilter == null,
              onTap: () {
                widget.onFilterSelected(null);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
