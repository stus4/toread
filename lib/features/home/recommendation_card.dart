import 'package:flutter/material.dart';
import '../../models/recommendation.dart';

class RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;
  final VoidCallback onTap;

  RecommendationCard({required this.recommendation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: Offset(0, 4))
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Обкладинка
              Container(
                width: 70,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFD4C4B0), Color(0xFFC4A484)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: Offset(0, 3))
                  ],
                ),
                child: Icon(Icons.book, color: Colors.white, size: 28),
              ),
              SizedBox(width: 16),
              // Контент
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.title,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5A4037)),
                    ),
                    SizedBox(height: 6),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFF8B6F47).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Автор: ${recommendation.author}',
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8B6F47),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Жанри: ${recommendation.genres.join(', ')}',
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFA68B5B),
                            fontStyle: FontStyle.italic),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text('Теги: ${recommendation.tags.join(', ')}',
                        style:
                            TextStyle(fontSize: 11, color: Color(0xFFB8956F)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    SizedBox(height: 8),
                    Text(
                      recommendation.description,
                      style: TextStyle(
                          fontSize: 13, color: Color(0xFF6B4E3D), height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatIcon(Icons.thumb_up, recommendation.likes),
                        _buildStatIcon(Icons.visibility, recommendation.views),
                        _buildStatIcon(Icons.bookmark, recommendation.saved),
                        _buildStatIcon(Icons.menu_book, recommendation.read),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatIcon(IconData icon, int count) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color(0xFFE8DDD4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Color(0xFF8B6F47)),
          SizedBox(width: 4),
          Text(count.toString(),
              style: TextStyle(
                  color: Color(0xFF8B6F47),
                  fontSize: 12,
                  fontWeight: FontWeight.w600))
        ],
      ),
    );
  }
}
