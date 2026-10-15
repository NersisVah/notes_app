class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String search = '/search';

  /// Create/edit note screen. Without an id it creates a new note.
  static const String note = '/note';
  static const String noteIdParam = 'id';

  static String noteById(String id) =>
      Uri(path: note, queryParameters: {noteIdParam: id}).toString();
}
