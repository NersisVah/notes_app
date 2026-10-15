// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_bloc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotesState _$NotesStateFromJson(Map<String, dynamic> json) => NotesState(
  notes:
      (json['notes'] as List<dynamic>?)
          ?.map((e) => NoteModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$NotesStateToJson(NotesState instance) =>
    <String, dynamic>{'notes': instance.notes.map((e) => e.toJson()).toList()};
