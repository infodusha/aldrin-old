import 'dart:async';

import 'package:aldrin/definitions.dart';

import 'context.dart';

class ContextBox<T> {
  final ContextValue<T> _contextValue;
  T value;

  ContextBox(this.value, this._contextValue);
}

class ContextValue<T> {
  set value(T value) {
    if (!Context.hasCurrent) {
      throw Exception('Unable to set value without context');
    }
    _box.value = value;
  }

  T get value {
    if (!Context.hasCurrent) {
      throw Exception('Unable to get value without context');
    }
    return _box.value;
  }

  ContextBox<T> get _box {
    return Context.current.boxes.firstWhere((v) => v._contextValue == this) as ContextBox<T>;
  }

  ContextValue(T initialValue) {
    OnMountDef(() {
      ContextBox<T> contentBox = ContextBox(initialValue, this);
      Context.current.boxes.add(contentBox);
    });

    OnUnMountDef(() {
      // FIXME !!!
      // Context.current.boxes.remove(_box);
    });
  }
}

class ContextValueSafe<T> extends ContextValue<T> {
  final T _initialValue;

  @override
  set value(T value) {
    if (Context.hasCurrent) {
      super.value = value;
    } else {
      print('Warning: You tried to set safe state outside of context');
    }
  }

  @override
  T get value {
    if (!Context.hasCurrent) {
      return _initialValue;
    }
    return super.value;
  }

  ContextValueSafe(this._initialValue): super(_initialValue);
}

class ContextState<T> extends ContextValueSafe<T> {
  final StreamController<T> _controller = StreamController.broadcast();

  Stream<T> get onChange {
    Context context = Context.current;
    return _controller.stream.where((_) => Context.current.id == context.id);
  }

  @override
  T get value {
    return super.value;
  }

  @override
  set value(T value) {
    super.value = value;
    _controller.add(value);
  }

  ContextState(T initialValue): super(initialValue);
}

