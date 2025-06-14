import 'package:flutter/material.dart';
import 'package:toread/models/recommendation.dart';

class WorkDetailScreen extends StatelessWidget {
  final Recommendation work;

  WorkDetailScreen({required this.work});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(work.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Автор: ${work.author}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Жанри: ${work.genres.join(', ')}'),
            Text('Теги: ${work.tags.join(', ')}'),
            SizedBox(height: 16),
            Text(work.description),
          ],
        ),
      ),
    );
  }
}
