import 'dart:async';

import 'package:aldrin/context.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import 'context_data.dart';


class StateDef<T> {
  static List<ContextState>? _reads;

  final ContextState<T> _contextState;

  T get value {
    _reads?.add(_contextState);
    return _contextState.value;
  }

  set value(T value) {
    _contextState.value = value;
  }

  StateDef(T initialValue): _contextState = ContextState(initialValue);

  static Tuple2<R, Stream<void>> getValueAndChanger<R>(R Function() fn) {
    StateDef._reads = [];
    R res = fn();
    List<ContextState> reads = StateDef._reads!;
    StateDef._reads = null;
    Stream<void> onChange = Rx.race(reads.map((s) => s.onChange).take(1));
    return Tuple2(res, onChange);
  }
}

class OnMountDef {
  static final List<OnMountDef> _initial = [];

  final void Function() _callback;

  OnMountDef(this._callback) {
    if (!Context.hasCurrent) {
      _initial.add(this); // FIXME we should skip in case the cause component is not visible
    } else {
      _callback();
    }
  }

  static init() {
    for (OnMountDef def in _initial) {
      def._callback();
    }
  }
}

// TODO implement
class OnUnMountDef {
  static final List<OnUnMountDef> _list = [];

  final void Function() _callback;

  OnUnMountDef(this._callback) {
    _list.add(this);
  }

  static run() {
    for (OnUnMountDef def in _list) {
      def._callback();
    }
  }
}
