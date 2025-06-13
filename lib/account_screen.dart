import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'draft_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  List<Map<String, String>> drafts = [];

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  Future<void> _loadDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    final List<Map<String, String>> loadedDrafts = [];

    // Шукаємо всі ключі, пов’язані з чернетками
    final workIds = <String>{};
    for (var key in keys) {
      if (key.endsWith('_draft_text')) {
        final workId = key.replaceAll('_draft_text', '');
        workIds.add(workId);
      }
    }

    for (var workId in workIds) {
      final title = prefs.getString('${workId}_draft_title') ?? 'Без назви';
      final text = prefs.getString('${workId}_draft_text') ?? '';
      loadedDrafts.add({'workId': workId, 'title': title, 'text': text});
    }

    setState(() {
      drafts = loadedDrafts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Мій акаунт / Чернетки")),
      body: drafts.isEmpty
          ? const Center(child: Text('Немає збережених чернеток'))
          : ListView.builder(
              itemCount: drafts.length,
              itemBuilder: (context, index) {
                final draft = drafts[index];
                return ListTile(
                  title: Text(draft['title'] ?? ''),
                  subtitle: Text(
                    draft['text']!.length > 100
                        ? '${draft['text']!.substring(0, 100)}...'
                        : draft['text']!,
                  ),
                  onTap: () {
                    // Перейти до редагування (можна передати workId)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditDraftScreen(
                          workId: draft['workId']!,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
