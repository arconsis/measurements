import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:measurements/scale_bloc/scale_bloc.dart';
import 'package:measurements/scale_bloc/scale_event.dart';
import 'package:measurements/scale_bloc/scale_state.dart';

///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

void main() {
  group("Scale Bloc Test", () {
    blocTest(
      "initial state",
      build: () async => GestureBloc(),
      skip: 0,
      expect: [
        GestureState(Offset(0, 0), 1.0, Matrix4.identity()),
      ],
    );

    blocTest(
      "panning",
      build: () async => GestureBloc(),
      act: (bloc) async {
        bloc.add(GestureScaleStartEvent(Offset(0, 0)));
        bloc.add(GestureScaleUpdateEvent(Offset(10, 0), 1.0));
      },
      expect: [
        GestureState(Offset(10, 0), 1.0, Matrix4.identity()..translate(10.0)),
      ],
    );

    blocTest(
      "zooming",
      build: () async => GestureBloc(),
      act: (bloc) async {
        bloc.add(GestureScaleStartEvent(Offset(0, 0)));
        bloc.add(GestureScaleUpdateEvent(Offset(10, 0), 2.0));
      },
      expect: [
        GestureState(Offset(0, 0), 2.0, Matrix4.identity()..scale(2)),
      ],
    );

    blocTest(
      "zoom and then pan",
      build: () async => GestureBloc(),
      act: (bloc) async {
        bloc.add(GestureScaleStartEvent(Offset(0, 0)));
        bloc.add(GestureScaleUpdateEvent(Offset(10, 0), 2.0));

        bloc.add(GestureScaleStartEvent(Offset(0, 0)));
        bloc.add(GestureScaleUpdateEvent(Offset(10, 0), 1.0));
      },
      expect: [
        GestureState(
            Offset(10, 0),
            2.0,
            Matrix4.identity()
              ..translate(10)
              ..scale(2)),
      ],
    );

    blocTest(
      "zoom twice",
      build: () async => GestureBloc(),
      act: (bloc) async {
        bloc.add(GestureScaleStartEvent(Offset(0, 0)));
        bloc.add(GestureScaleUpdateEvent(Offset(10, 0), 2.0));

        bloc.add(GestureScaleStartEvent(Offset(0, 0)));
        bloc.add(GestureScaleUpdateEvent(Offset(10, 0), 3.0));
      },
      expect: [
        GestureState(Offset(0, 0), 6.0, Matrix4.identity()..scale(6)),
      ],
    );
  });
}
