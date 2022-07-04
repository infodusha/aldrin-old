import 'package:aldrin/components/elements.dart';

abstract class Component {
  String render();
  Component? parent;

  T getParent<T extends Component>() {
    Component? i = parent;
    while (i != null) {
      if (i is T) {
        return i;
      }
      i = i.parent;
    }
    throw Exception('Unable to get parent of type $T');
  }
}

class Fragment extends Component {
  final List<Component> children;

  Fragment(this.children) {
    for (Component child in children) {
      child.parent = this;
    }
  }

  int getChildIndex(Component child) {
    return children.where((e) {
      if (e is IfElement && e != child) {
        return e.isRendered.value;
      }
      return true;
    }).toList().indexOf(child);
  }

  @override
  String render() {
    return children.map((child) => child.render()).join();
  }
}
