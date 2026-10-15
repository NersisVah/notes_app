import 'package:json_annotation/json_annotation.dart';

part 'note_model.g.dart';

@JsonSerializable()
class NoteModel {
  const NoteModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) =>
      _$NoteModelFromJson(json);

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;

  Map<String, dynamic> toJson() => _$NoteModelToJson(this);

  NoteModel copyWith({
    String? title,
    String? body,
    DateTime? updatedAt,
    bool? isFavorite,
  }) {
    return NoteModel(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteModel &&
          other.id == id &&
          other.title == title &&
          other.body == body &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt &&
          other.isFavorite == isFavorite;

  @override
  int get hashCode =>
      Object.hash(id, title, body, createdAt, updatedAt, isFavorite);
}
