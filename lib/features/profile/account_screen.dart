import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../works/draft_screen.dart';
import '../works/work_detail_screen.dart';
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
      backgroundColor: const Color(0xFFFAF8F5), // М'який кремовий фон
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок "Уподобані"
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFE6D7C8), // М'який бежевий
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFD4C4B0),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB8A082).withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                "Уподобані",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B5B4D),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 18),
            likedWorks.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EBE4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFE1D5C7),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      "Немає уподобаних робіт",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF8A7968),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: likedWorks.length,
                      itemBuilder: (context, index) {
                        final work = likedWorks[index];
                        return GestureDetector(
                          onTap: () {
                            final workObj = Recommendation.fromJson(work);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WorkDetailScreen(
                                      work: workObj,
                                      workId: workObj.id.toString())),
                            );
                          },
                          child: Container(
                            width: 130,
                            margin: const EdgeInsets.only(right: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8DDD2), // М'який бежевий
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFD6C8B8),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFFB8A082).withOpacity(0.12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // М'який декоративний акцент
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFC4B49A),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      work['title'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF6B5B4D),
                                        height: 1.3,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 32),

            // Заголовок "Збережені роботи"
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFDACBBA), // Трохи темніший бежевий
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFC8B69F),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB0956F).withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                "Збережені роботи",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5D4E42),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 18),
            savedWorks.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EBE4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFE1D5C7),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      "Немає збережених робіт",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF8A7968),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: savedWorks.length,
                      itemBuilder: (context, index) {
                        final work = savedWorks[index];
                        return GestureDetector(
                          onTap: () {
                            final workObj = Recommendation.fromJson(work);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WorkDetailScreen(
                                      work: workObj,
                                      workId: workObj.id.toString())),
                            );
                          },
                          child: Container(
                            width: 130,
                            margin: const EdgeInsets.only(right: 14),
                            decoration: BoxDecoration(
                              color: const Color(
                                  0xFFDDD0C0), // Теплий сірувато-бежевий
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFCABDA8),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFFAD9375).withOpacity(0.12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // М'який декоративний акцент
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFB5A088),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      work['title'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF5D4E42),
                                        height: 1.3,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 32),

            // Заголовок "Чернетки"
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFD1C1AE), // Найтемніший з м'яких тонів
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFBFAE95),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA68B65).withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                "Чернетки",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF544438),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 18),
            drafts.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EBE4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFE1D5C7),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      'Немає збережених чернеток',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF8A7968),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
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
                            margin: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              color: const Color(
                                  0xFFF5F0E8), // Дуже м'який кремовий
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFE5D8C8),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFFCBB896).withOpacity(0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // М'який кутовий акцент
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFD4C4B0),
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(19),
                                        bottomLeft: Radius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        draft['title'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF5D4E42),
                                          height: 1.2,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        height: 1.5,
                                        width: 35,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFD4C4B0),
                                          borderRadius:
                                              BorderRadius.circular(1),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Expanded(
                                        child: Text(
                                          draft['text']!.length > 100
                                              ? '${draft['text']!.substring(0, 100)}...'
                                              : draft['text']!,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF7A6B5D),
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
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
