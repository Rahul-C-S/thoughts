import 'dart:convert';

class NoteModel {
  final String id;
  final String title;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'note': note,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as String,
      title: map['title'] as String,
      note: map['note'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['created_at'] is int
            ? map['created_at'] as int
            : int.parse(map['created_at']),
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['updated_at'] is int
            ? map['updated_at'] as int
            : int.parse(map['updated_at']),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory NoteModel.fromJson(String source) =>
      NoteModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
