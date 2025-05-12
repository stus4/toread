class Recommendation {
  final String title;
  final String description;

  Recommendation({required this.title, required this.description});

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      title: json['title'],
      description: json['description'],
    );
  }
}
