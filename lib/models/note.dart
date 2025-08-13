class Note {
  String id;
  String title;
  String content; // Stored as JSON for rich text (flutter_quill)
  DateTime createdAt;
  String? imageUrl;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'imageUrl': imageUrl,
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        createdAt: DateTime.parse(json['createdAt']),
        imageUrl: json['imageUrl'],
      );
}