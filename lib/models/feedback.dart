class Feedback {
  final int? id;
  final String date;
  final String category;
  final String content;
  final String createdAt;

  Feedback({
    this.id,
    required this.date,
    required this.category,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'category': category,
      'content': content,
      'created_at': createdAt,
    };
  }

  factory Feedback.fromMap(Map<String, dynamic> map) {
    return Feedback(
      id: map['id'],
      date: map['date'],
      category: map['category'],
      content: map['content'],
      createdAt: map['created_at'],
    );
  }
} 