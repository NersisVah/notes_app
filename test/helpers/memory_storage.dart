import 'package:hydrated_bloc/hydrated_bloc.dart';

/// In-memory [Storage] so HydratedBloc works in tests without disk access.
class MemoryStorage implements Storage {
  final Map<String, dynamic> values = {};

  @override
  dynamic read(String key) => values[key];

  @override
  Future<void> write(String key, dynamic value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<void> clear() async => values.clear();

  @override
  Future<void> close() async {}
}
