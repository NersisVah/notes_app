import 'package:notes_app/domain/model/note_model.dart';

/// A note with a fixed id and dates. A higher [index] means created and
/// updated later, so it sorts higher in "newest first" lists.
///
/// Dates are local (not UTC) so screens that print them show the same text
/// in every time zone.
NoteModel testNote(
  int index, {
  String? title,
  String? body,
  bool isFavorite = false,
  Duration editedAfter = Duration.zero,
}) {
  final createdAt = DateTime(2026, 1, 1, 9).add(Duration(hours: index));
  return NoteModel(
    id: 'note-$index',
    title: title ?? 'Note $index',
    body: body ?? 'Body of note $index',
    createdAt: createdAt,
    updatedAt: createdAt.add(editedAfter),
    isFavorite: isFavorite,
  );
}
