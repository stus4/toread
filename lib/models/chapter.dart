class Chapter {
  final String id;
  final String title;
  final String? content;
  final int num;
  final String workId;

  Chapter({
    required this.id,
    required this.title,
    this.content,
    required this.num,
    required this.workId,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      num: json['num'],
      workId: json['work_id'],
    );
  }
}
