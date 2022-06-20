import 'package:aldrin/components/elements.dart';

abstract class Component {
  String render();
  Component? parent;

  T getParent<T extends Component>() {
    var i = parent;
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
    for (var child in children) {
      child.parent = this;
    }
  }

  getChildIndex(Component child) {
    return children.where((e) => (e is IfElement && e != child) ? e.condition.value : true).toList().indexOf(child);
  }

  @override
  String render() {
    return children.map((child) => child.render()).join();
  }
}
