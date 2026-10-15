class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String search = '/search';
  static const String newNote = '/note';
  static const String note = '/note/:id';

  static String noteById(String id) => '/note/$id';
}
