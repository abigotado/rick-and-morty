import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty/core/bloc/debounce_restartable.dart';

const _window = Duration(milliseconds: 20);

class _LogBloc extends Bloc<int, List<String>> {
  _LogBloc({Map<int, Completer<void>> work = const {}}) : super(const []) {
    on<int>(
      (event, emit) async {
        emit([...state, 'start $event']);
        await work[event]?.future;
        emit([...state, 'done $event']);
      },
      transformer: debounceRestartable(_window),
    );
  }
}

void main() {
  late Map<int, Completer<void>> work;

  setUp(() {
    work = {1: Completer<void>(), 2: Completer<void>()};
  });

  group('debounceRestartable', () {
    blocTest<_LogBloc, List<String>>(
      'events within the window → only the last one is handled',
      build: _LogBloc.new,
      act: (bloc) => bloc
        ..add(1)
        ..add(2)
        ..add(3),
      wait: _window * 5,
      expect: () => [
        ['start 3'],
        ['start 3', 'done 3'],
      ],
    );

    blocTest<_LogBloc, List<String>>(
      'event after the previous one was handled → both are handled',
      build: _LogBloc.new,
      act: (bloc) async {
        bloc.add(1);
        await bloc.stream.firstWhere((log) => log.contains('done 1'));
        bloc.add(2);
      },
      wait: _window * 5,
      expect: () => [
        ['start 1'],
        ['start 1', 'done 1'],
        ['start 1', 'done 1', 'start 2'],
        ['start 1', 'done 1', 'start 2', 'done 2'],
      ],
    );

    blocTest<_LogBloc, List<String>>(
      'newer event while a handler is running → the running handler never emits again',
      build: () => _LogBloc(work: work),
      act: (bloc) async {
        bloc.add(1);
        await bloc.stream.firstWhere((log) => log.contains('start 1'));
        bloc.add(2);
        await bloc.stream.firstWhere((log) => log.contains('start 2'));
        work[1]!.complete();
        work[2]!.complete();
      },
      expect: () => [
        ['start 1'],
        ['start 1', 'start 2'],
        ['start 1', 'start 2', 'done 2'],
      ],
    );

    // testWidgets runs on a fake clock and fails the test if any timer is still pending at the end.
    testWidgets('bloc closed before the window elapses → no debounce timer left pending', (
      tester,
    ) async {
      final bloc = _LogBloc()..add(1);
      await tester.pump();

      unawaited(bloc.close());
      await tester.pump();

      expect(bloc.isClosed, isTrue);
    });
  });
}
