import 'package:flutter/material.dart';
import '../../models/recommendation.dart';
import 'recommendation_card.dart';
import '../filters/filter_sort_dialogs.dart';

class HomeBody extends StatelessWidget {
  final List<Recommendation> recommendations;
  final List<Recommendation> popularWorks;
  final Function(Recommendation) onOpenWork;
  final VoidCallback onFilter;
  final VoidCallback onSort;

  HomeBody({
    required this.recommendations,
    required this.popularWorks,
    required this.onOpenWork,
    required this.onFilter,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= Популярне =================
          if (popularWorks.isNotEmpty) ...[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.trending_up, color: Color(0xFF8B6F47)),
                  SizedBox(width: 8),
                  Text(
                    'Популярне',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5A4037),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 12),
                itemCount: popularWorks.length,
                itemBuilder: (context, index) {
                  final work = popularWorks[index];
                  return Container(
                    width: 200,
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    child: RecommendationCard(
                      recommendation: work,
                      onTap: () => onOpenWork(work),
                    ),
                  );
                },
              ),
            ),
          ],

          SizedBox(height: 20),

          // ================= Рекомендоване =================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(Icons.recommend, color: Color(0xFF8B6F47)),
                SizedBox(width: 8),
                Text(
                  'Рекомендоване для вас',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5A4037),
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.filter_list, color: Color(0xFF6B4E3D)),
                  onPressed: onFilter,
                ),
                IconButton(
                  icon: Icon(Icons.sort, color: Color(0xFF6B4E3D)),
                  onPressed: onSort,
                ),
              ],
            ),
          ),

          Column(
            children: recommendations.isEmpty
                ? [
                    SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.library_books,
                              size: 48, color: Color(0xFFD4C4B0)),
                          SizedBox(height: 8),
                          Text(
                            'Немає доступних рекомендацій',
                            style: TextStyle(
                                color: Color(0xFF5A4037), fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ]
                : recommendations
                    .map((r) => RecommendationCard(
                          recommendation: r,
                          onTap: () => onOpenWork(r),
                        ))
                    .toList(),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }
}
