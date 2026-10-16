import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Waits for [duration] of silence before handling an event; a newer event cancels both the
/// pending wait and an in-flight handler.
EventTransformer<E> debounceRestartable<E>(Duration duration) {
  final restart = restartable<E>();
  return (events, mapper) => restart(
    events,
    (event) => Stream<void>.periodic(duration).take(1).asyncExpand((_) => mapper(event)),
  );
}
