class Comment {
  final String id;
  final String userName;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userName,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'].toString(),
      userName: json['user_name'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}