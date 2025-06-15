import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'draft_screen.dart';
import 'work_detail_screen.dart';
import 'package:toread/models/recommendation.dart';

class AccountScreen extends StatefulWidget {
  final String userId;

  const AccountScreen({required this.userId, super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Recommendation? openedWork;
  List<Map<String, dynamic>> likedWorks = [];
  List<Map<String, dynamic>> savedWorks = [];
  List<Map<String, dynamic>> drafts = [];

  @override
  void initState() {
    super.initState();
    _loadDrafts();
    _fetchLikedWorks();
    _fetchSavedWorks();
  }

  Future<void> _loadDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    final List<Map<String, dynamic>> loadedDrafts = [];

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

  Future<void> _fetchLikedWorks() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/users/liked_works/${widget.userId}'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          likedWorks = List<Map<String, dynamic>>.from(data);
        });
      } else {
        print('Failed to load liked works, status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching liked works: $e');
    }
  }

  Future<void> _fetchSavedWorks() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/users/saved_works/${widget.userId}'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          savedWorks = List<Map<String, dynamic>>.from(data);
        });
      } else {
        print('Failed to load saved works, status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching saved works: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Уподобані",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            likedWorks.isEmpty
                ? const Text("Немає уподобаних робіт")
                : SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: likedWorks.length,
                      itemBuilder: (context, index) {
                        final work = likedWorks[index];
                        return GestureDetector(
                          onTap: () {
                            final workObj = Recommendation.fromJson(
                                work); // ← тут 'work' це Map
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    WorkDetailScreen(work: workObj),
                              ),
                            );
                          },
                          child: Container(
                            width: 120,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                work['title'] ?? '',
                                style: const TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 30),
            const Text("Збережені роботи",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            savedWorks.isEmpty
                ? const Text("Немає збережених робіт")
                : SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: savedWorks.length,
                      itemBuilder: (context, index) {
                        final work = savedWorks[index];
                        return GestureDetector(
                          onTap: () {
                            final workObj = Recommendation.fromJson(
                                work); // ← тут 'work' це Map
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    WorkDetailScreen(work: workObj),
                              ),
                            );
                          },
                          child: Container(
                            width: 120,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                work['title'] ?? '',
                                style: const TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 30),
            const Text("Чернетки",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            drafts.isEmpty
                ? const Text('Немає збережених чернеток')
                : SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: drafts.length,
                      itemBuilder: (context, index) {
                        final draft = drafts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditDraftScreen(workId: draft['workId']!),
                              ),
                            );
                          },
                          child: Container(
                            width: 220,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  draft['title'] ?? '',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: Text(
                                    draft['text']!.length > 150
                                        ? '${draft['text']!.substring(0, 150)}...'
                                        : draft['text']!,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
