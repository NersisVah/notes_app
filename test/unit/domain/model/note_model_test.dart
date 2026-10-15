import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/domain/model/note_model.dart';

import '../../../helpers/test_notes.dart';

void main() {
  group('NoteModel', () {
    test('toJson and fromJson round-trip every field', () {
      final note = testNote(
        1,
        isFavorite: true,
        editedAfter: const Duration(minutes: 5),
      );
      expect(NoteModel.fromJson(note.toJson()), note);
    });

    test('a missing isFavorite in JSON defaults to false', () {
      final json = testNote(1).toJson()..remove('isFavorite');
      expect(NoteModel.fromJson(json).isFavorite, isFalse);
    });

    test(
      'copyWith changes only the given fields and keeps id and createdAt',
      () {
        final note = testNote(1);
        final changed = note.copyWith(title: 'New', isFavorite: true);
        expect(changed.title, 'New');
        expect(changed.isFavorite, isTrue);
        expect(changed.id, note.id);
        expect(changed.body, note.body);
        expect(changed.createdAt, note.createdAt);
        expect(changed.updatedAt, note.updatedAt);
      },
    );

    test('notes with the same values are equal and share a hash code', () {
      expect(testNote(1), testNote(1));
      expect(testNote(1).hashCode, testNote(1).hashCode);
      expect(testNote(1), isNot(testNote(1, isFavorite: true)));
    });
  });
}
