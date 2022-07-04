import 'dart:async';

import 'package:aldrin/components/components.dart';
import 'package:aldrin/context.dart';
import 'package:aldrin/context_data.dart';
import 'package:aldrin/definitions.dart';
import 'package:aldrin/components/nodes.dart';
import 'package:tuple/tuple.dart';

import '../actions.dart';

class _StatesWatcher<T> {
  final StreamController<void> _controller = StreamController.broadcast();
  final T Function() _fn;
  final ContextValue<StreamSubscription<void>?> _contextSub = ContextValue(null);

  Stream<void> get onChange {
    Context context = Context.current;
    return _controller.stream.where((_) => Context.current.id == context.id);
  }

  _StatesWatcher(this._fn);

  T getValue() {
    Tuple2<T, Stream<void>> valueAndChanger = StateDef.getValueAndChanger(_fn);
    _contextSub.value?.cancel();
    _contextSub.value = valueAndChanger.item2.listen((_) => _controller.add(null));
    return valueAndChanger.item1;
  }

}

class IfElement extends Component {
  final EmitActions _emitter = EmitActions();
  final _StatesWatcher<bool> _statesWatcher;
  final String _childRender;
  final String? _elseChildRender;
  final Component _child;
  final bool Function() _condition;
  final ContextValue<bool> isRendered = ContextValue(false);
  final ContextValue<StreamSubscription<void>?> _sub = ContextValue(null);

  void onChange(_) {
    Node parentNode = getParent();
    Fragment parentFragment = getParent();

    final bool value = _statesWatcher.getValue();
    isRendered.value = value;

    int i = parentFragment.getChildIndex(this);
    if (i == -1) {
      throw Exception('Unable to get index');
    }

    String? elseChildRender = _elseChildRender;
    Component child = _child;
    int l = child is Fragment ? child.children.length : 1;

    if (value) {
      if (elseChildRender != null) {
        _emitter.removeElement(parentNode.id, i, l);
      }
      _emitter.createElement(parentNode.id, i, _childRender);
    } else {
      if (elseChildRender != null) {
        _emitter.removeElement(parentNode.id, i, l);
        _emitter.createElement(parentNode.id, i, elseChildRender);
      } else {
        _emitter.removeElement(parentNode.id, i, l);
      }
    }
  }

  IfElement(this._condition, this._child, { Component? elseChild }):
        _childRender = _child.render(),
        _elseChildRender = elseChild?.render(),
        _statesWatcher = _StatesWatcher(_condition)
  {
    _child.parent = this;

    OnMountDef(() {
      isRendered.value = _condition();
      _sub.value = _statesWatcher.onChange.listen(onChange);
      _statesWatcher.getValue(); // FIXME that is not clear
    });

    OnUnMountDef(() {
      _sub.value?.cancel();
    });
  }

  @override
  String render() {
    if (_condition()) {
      return _childRender;
    }
    return _elseChildRender ?? '';
  }
}

class ViewElement extends Component {
  final EmitActions _emitter = EmitActions();
  final _StatesWatcher<Component?> _statesWatcher;
  final Component? Function() _condition;
  final ContextValue<Component?> _value = ContextValue(null);
  final ContextValue<StreamSubscription<void>?> _sub = ContextValue(null);

  void onChange(_) {
    Component? prevValue = _value.value;
    Component? value  = _statesWatcher.getValue();
    _value.value = value;

    Node parentNode = getParent();
    Fragment parentFragment = getParent();

    int i = parentFragment.getChildIndex(this);
    if (i == -1) {
      i = 0; // FIXME
      // throw Exception('Unable to get index');
    }

    if (prevValue == null && value != null) {
      value.parent = this;
      _emitter.createElement(parentNode.id, i, value.render());
    } else if (value != null) {
      _emitter.replaceElement(parentNode.id, value.render());
    } else {
      int l = prevValue is Fragment ? prevValue.children.length : 1;
      _emitter.removeElement(parentNode.id, i, l);
    }
  }

  ViewElement(this._condition) : _statesWatcher = _StatesWatcher(_condition) {
    OnMountDef(() {
      _value.value = _condition();
      _sub.value = _statesWatcher.onChange.listen(onChange);
      _statesWatcher.getValue(); // FIXME that is not clear
    });

    OnUnMountDef(() {
      _sub.value?.cancel();
    });
  }

  @override
  String render() {
    Component? value = _condition();
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

// class ForElement<T> extends Component {
//   final EmitActions _emitter = EmitActions();
//   final StateDef<List<T>> _stateDef;
//   final Component Function(T e) _renderChild;
//   List<T> _prevValue;
//
//   int _update(List<T> minValue) {
//     Node parentNode = getParent();
//
//     List<T> value = _stateDef.value;
//     int index = 0;
//     while (index < minValue.length) {
//       if (value[index] != _prevValue[index]) {
//         _emitter.replaceElement(parentNode.id, _getChildHtml(value[index]));
//       }
//       index++;
//     }
//     return index;
//   }
//
//   void _onChange(List<T> value) {
//     if (value == _prevValue) {
//       return;
//     }
//
//     // TODO add optional trackBy parameter
//
//     if (value.length == _prevValue.length) {
//       // Update
//       _update(value);
//     } else if (value.length > _prevValue.length) {
//       // Update + add
//       int addAfter = _update(_prevValue);
//       Node parentNode = getParent();
//       value.sublist(addAfter).forEach((e) {
//         _emitter.createElement(parentNode.id, addAfter, _getChildHtml(e));
//       });
//     } else {
//       // Update + remove
//       int removeAfter = _update(value);
//       Node parentNode = getParent();
//       _emitter.removeElement(parentNode.id, removeAfter, _prevValue.length - removeAfter);
//     }
//
//     _prevValue = value;
//   }
//
//   String _getChildHtml(T e) {
//     Component child = _renderChild(e);
//     child.parent = this;
//     return child.render();
//   }
//
//   ForElement(this._stateDef, this._renderChild): _prevValue = _stateDef.value {
//     OnMountDef(() {
//       _stateDef.contextState.onChange.listen(_onChange);
//     });
//   }
//
//   @override
//   String render() {
//     return _stateDef.value.map(_getChildHtml).join();
//   }
// }
