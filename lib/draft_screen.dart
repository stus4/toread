import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditDraftScreen extends StatefulWidget {
  final String workId;
  const EditDraftScreen({super.key, required this.workId});

  @override
  State<EditDraftScreen> createState() => _EditDraftScreenState();
}

class _EditDraftScreenState extends State<EditDraftScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final title = prefs.getString('${widget.workId}_draft_title') ?? '';
    final text = prefs.getString('${widget.workId}_draft_text') ?? '';

    setState(() {
      _titleController.text = title;
      _textController.text = text;
    });
  }

  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        '${widget.workId}_draft_title', _titleController.text.trim());
    await prefs.setString(
        '${widget.workId}_draft_text', _textController.text.trim());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Чернетку збережено')),
    );
  }

  Future<void> _deleteDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${widget.workId}_draft_title');
    await prefs.remove('${widget.workId}_draft_text');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Чернетку видалено')),
    );

    Navigator.pop(context); // Повернутись назад
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Редагувати чернетку")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Назва розділу',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  labelText: 'Текст розділу',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveDraft,
                    child: const Text("Зберегти"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _deleteDraft,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("Видалити"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
