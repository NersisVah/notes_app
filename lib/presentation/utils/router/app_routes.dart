class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String search = '/search';

  /// Create/edit note screen. Without an id it creates a new note.
  static const String note = '/note';
  static const String noteIdParam = 'id';

  static String noteById(String id) =>
      Uri(path: note, queryParameters: {noteIdParam: id}).toString();

  /// Read-only note screen with edit, favorite and delete actions.
  static const String noteDetails = '/note-details';

  static String noteDetailsById(String id) =>
      Uri(path: noteDetails, queryParameters: {noteIdParam: id}).toString();
}
