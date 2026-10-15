import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

/// Runs [act] on [bloc] and returns every state it emitted, in order.
///
/// A small stand-in for `blocTest` from package:bloc_test, which can't be
/// installed next to this project's json_serializable/build_runner versions.
Future<List<S>> statesEmittedBy<B extends BlocBase<S>, S>(
  B bloc,
  FutureOr<void> Function(B bloc) act,
) async {
  final states = <S>[];
  final subscription = bloc.stream.listen(states.add);
  await act(bloc);
  // Bloc handles events asynchronously; let queued work finish.
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
  await subscription.cancel();
  return states;
}
