import 'package:flutter/material.dart';
import 'package:toread/settings/security.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = {
      'Обліковий запис': () {},
      'Відображення та інтерфейс': () {},
      'Сповіщення та взаємодія': () {},
      'Контент і рекомендації': () {},
      'Безпека та доступ': () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SecurityScreen()),
        );
      },
      'Підтримка та допомога': () {},
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Налаштування'),
      ),
      body: ListView(
        children: sections.entries.map((entry) {
          return ListTile(
            title: Text(entry.key),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: entry.value,
          );
        }).toList(),
      ),
    );
  }
}
