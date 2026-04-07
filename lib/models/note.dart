class Note {
  final String id;
  String title;
  String content;
  DateTime lastEdited;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.lastEdited,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'lastEdited': lastEdited.toIso8601String(),
  };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    lastEdited: DateTime.parse(json['lastEdited']),
  );
}
