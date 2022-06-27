import 'dart:async';

import 'package:aldrin/components/components.dart';
import 'package:aldrin/definitions.dart';
import 'package:aldrin/components/nodes.dart';

import '../actions.dart';

abstract class _WatchStates<T> extends Component {
  final List<StreamSubscription> _subs = [];

  late T _value; // TODO that should be values per context.id
  final T Function() _getValue;

  _WatchStates(this._getValue);

  void onChange(T? prevValue, T value);

  void _onChange(_) {
    T prevValue = _value;

    _value = getValue();

    // That thing may be need to have optional algo
    if (_value == prevValue) {
      return;
    }

    onChange(prevValue, _value);
  }

  T getValue() {
    for (StreamSubscription sub in _subs) {
      sub.cancel();
    }

    _subs.clear();

    _value = _getValue();

    OnMountDef(() {
      for (StateDef state in StateDef.lastRead) {
        final sub = state.onChange.listen(_onChange);
        _subs.add(sub);
      }
    });
    // if (Context.hasCurrent) {
    //   for (StateDef state in StateDef.lastRead) {
    //     final sub = state.onChange.listen(_onChange);
    //     _subs.add(sub);
    //   }
    // }

    return _value;
  }
}

class IfElement extends _WatchStates<bool> {
  final EmitActions _emitter = EmitActions();
  final String _childRender;
  final String? _elseChildRender;
  final Component _child;

  bool isRendered = false;

  @override
  void onChange(bool? prevValue, bool value) {
    Node parentNode = getParent();
    Fragment parentFragment = getParent();

    isRendered = value;
    int i = parentFragment.getChildIndex(this);

    if (value) {
      if (_elseChildRender != null) {
        _emitter.replaceElement(parentNode.id, i, _childRender);
      } else {
        _emitter.createElement(parentNode.id, i, _childRender);
      }
    } else {
      String? elseChildRender = _elseChildRender;
      if (elseChildRender != null) {
        _emitter.replaceElement(parentNode.id, i, elseChildRender);
      } else {
        Component possibleFragment = _child;
        int l = possibleFragment is Fragment ? possibleFragment.children.length : 1;
        _emitter.removeElement(parentNode.id, i, l);
      }
    }
  }

  IfElement(bool Function() condition, this._child, { Component? elseChild }):
        _childRender = _child.render(),
        _elseChildRender = elseChild?.render(),
        super(condition)
  {
    _child.parent = this;
  }

  @override
  String render() {
    isRendered = getValue();
    if (isRendered) {
      return _childRender;
    }
    return _elseChildRender ?? '';
  }
}

class ViewElement extends _WatchStates<Component?> {
  final EmitActions _emitter = EmitActions();

  @override
  void onChange(Component? prevValue, Component? value) {
    Node parentNode = getParent();
    Fragment parentFragment = getParent();

    int i = parentFragment.getChildIndex(this);

    if (prevValue == null && value != null) {
      value.parent = this;
      _emitter.createElement(parentNode.id, i, value.render());
    } else if (value != null) {
      _emitter.replaceElement(parentNode.id, i, value.render());
    } else {
      int l = prevValue is Fragment ? prevValue.children.length : 1;
      _emitter.removeElement(parentNode.id, i, l);
    }
  }

  ViewElement(Component Function() condition): super(condition);

  @override
  String render() {
    Component? value = getValue();
    if (value == null) {
      return '';
    }
    value.parent = this;
    return value.render();
  }
}

class TextElement extends Component {
  final String text;

  TextElement(this.text);

  @override
  String render() {
    return text;
  }
}

class ForElement<T> extends Component {
  final EmitActions _emitter = EmitActions();
  final StateDef<List<T>> _stateDef;
  final Component Function(T e) _renderChild;
  List<T> _prevValue;

  int _update(List<T> minValue) {
    Node parentNode = getParent();
    Fragment parentFragment = getParent();

    int i = parentFragment.getChildIndex(this);
    List<T> value = _stateDef.value;
    int index = 0;
    while (index < minValue.length) {
      if (value[index] != _prevValue[index]) {
        _emitter.replaceElement(parentNode.id, i, _getChildHtml(value[index]));
      }
      index++;
    }
    return index;
  }

  void _onChange(List<T> value) {
    if (value == _prevValue) {
      return;
    }

    // TODO add optional trackBy parameter

    if (value.length == _prevValue.length) {
      // Update
      _update(value);
    } else if (value.length > _prevValue.length) {
      // Update + add
      int addAfter = _update(_prevValue);
      Node parentNode = getParent();
      value.sublist(addAfter).forEach((e) {
        _emitter.createElement(parentNode.id, addAfter, _getChildHtml(e));
      });
    } else {
      // Update + remove
      int removeAfter = _update(value);
      Node parentNode = getParent();
      _emitter.removeElement(parentNode.id, removeAfter, _prevValue.length - removeAfter);
    }

    _prevValue = value;
  }

  String _getChildHtml(T e) {
    Component child = _renderChild(e);
    child.parent = this;
    return child.render();
  }

  ForElement(this._stateDef, this._renderChild): _prevValue = _stateDef.value {
    _stateDef.onChange.listen(_onChange);
  }

  @override
  String render() {
    return _stateDef.value.map(_getChildHtml).join();
  }
}
