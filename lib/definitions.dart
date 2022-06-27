import 'dart:async';

import 'package:aldrin/context.dart';

class StateDef<T> {
  static final List<StateDef> lastRead = [];

  final T _initialValue;
  final Map<String, T> _values = {};
  final StreamController<String> _controller = StreamController.broadcast();

  Stream<T> get onChange {
    Context context = Context.current;
    return _controller.stream.where((id) => id == context.id).map((_) => value);
  }

  T get value {
    StateDef.lastRead.add(this);

    if (Context.hasCurrent) {
      Timer.run(_clearLastRead);
    }

    T? value = Context.hasCurrent ? _values[Context.current.id] : _initialValue;
    if (value == null) {
      return _initialValue;
    }
    return value;
  }

  set value(T value) {
    Context context = Context.current;
    T? prevValue = _values[context.id];
    if (prevValue == value) {
      return;
    }
    _values[context.id] = value;
    _controller.add(context.id);
  }

  StateDef(this._initialValue) {
    OnMountDef(() {
      // Context.current.states.add(this);
      Timer.run(_clearLastRead);
    });
  }

  _clearLastRead() {
    StateDef.lastRead.clear();
  }
}

class OnMountDef {
  static final List<OnMountDef> _initial = [];
  static bool _initialRun = false;

  final void Function() _callback;

  OnMountDef(this._callback) {
    if (!Context.hasCurrent) {
      if (_initialRun) {
        throw Exception('No context, but already mounted');
      }
      _initial.add(this);
    } else if (!_initial.contains(this)) { // TODO not sure that check makes sense
      _callback();
    }
  }

  static init() {
    for (OnMountDef def in _initial) {
      def._callback();
    }
    _initialRun = true;
  }
}
