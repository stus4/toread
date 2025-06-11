// recommendations_widget.dart
import 'package:flutter/material.dart';
import 'package:toread/models/recommendation.dart';

class RecommendationsList extends StatelessWidget {
  final Future<List<Recommendation>> recommendationsFuture;

  RecommendationsList({required this.recommendationsFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Recommendation>>(
      future: recommendationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Помилка завантаження рекомендацій'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Рекомендації відсутні'));
        } else {
          return ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final recommendation = snapshot.data![index];
              return RecommendationCard(recommendation: recommendation);
            },
          );
        }
      },
    );
  }
}

class PopularWorksList extends StatelessWidget {
  final Future<List<Recommendation>> popularWorksFuture;

  PopularWorksList({required this.popularWorksFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Recommendation>>(
      future: popularWorksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Помилка: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('Немає популярних творів');
        }

        final works = snapshot.data!;
        return Column(
          children: works.map((work) {
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: ListTile(
                title: Text(work.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Автор: ${work.author}'),
                    Text('Жанри: ${work.genres.join(', ')}'),
                    Text('Теги: ${work.tags.join(', ')}'),
                    Text(work.description),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatIcon(Icons.thumb_up, work.likes),
                        SizedBox(width: 16),
                        _buildStatIcon(Icons.visibility, work.views),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildStatIcon(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 4),
        Text(count.toString(), style: TextStyle(color: Colors.grey[700])),
      ],
    );
  }
}

class RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;

  RecommendationCard({required this.recommendation});

  Widget _buildStatIcon(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 4),
        Text(count.toString(), style: TextStyle(color: Colors.grey[700])),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        title: Text(recommendation.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Автор: ${recommendation.author}'),
            Text('Жанри: ${recommendation.genres.join(', ')}'),
            Text('Теги: ${recommendation.tags.join(', ')}'),
            Text(recommendation.description),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildStatIcon(Icons.thumb_up, recommendation.likes),
                SizedBox(width: 16),
                _buildStatIcon(Icons.visibility, recommendation.views),
                SizedBox(width: 16),
                _buildStatIcon(Icons.bookmark, recommendation.saved),
                SizedBox(width: 16),
                _buildStatIcon(Icons.menu_book, recommendation.read),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
