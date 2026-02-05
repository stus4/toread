import 'package:shared_preferences/shared_preferences.dart';

class LocalDraftStorage {
  // Збереження чернетки
  static Future<void> saveDraft(
      String workId, String title, String text) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${workId}_draft_title', title);
    await prefs.setString('${workId}_draft_text', text);
  }

  // Завантаження чернетки
  static Future<Map<String, String>> loadDraft(String workId) async {
    final prefs = await SharedPreferences.getInstance();
    final title = prefs.getString('${workId}_draft_title') ?? '';
    final text = prefs.getString('${workId}_draft_text') ?? '';
    return {'title': title, 'text': text};
  }

  // Видалення чернетки (опціонально)
  static Future<void> clearDraft(String workId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${workId}_draft_title');
    await prefs.remove('${workId}_draft_text');
  }
}
