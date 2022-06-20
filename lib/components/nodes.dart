import 'package:aldrin/components/components.dart';
import 'package:aldrin/server.dart';
import 'package:nanoid/nanoid.dart';

abstract class Node extends Component {
  final String id = nanoid();
  abstract final String tagName;

  final Map<String, String> _attributes = {};
  Component? child;

  Node({ this.child, String? className }) {
    child?.parent = this;
    _attributes['id'] = id;

    if (className != null) {
      _attributes['class'] = className;
    }
  }

  @override
  String render() {
    var attributes = _attributes.entries.map((entry) {
      return '${entry.key}="${entry.value}"';
    }).join(' ');
    return '<$tagName $attributes>${child?.render() ?? ''}</$tagName>';
  }
}

class DivNode extends Node {
  @override
  String tagName = 'div';

  DivNode({ Component? child, String? className }) : super(child: child, className: className);
}

class UlNode extends Node {
  @override
  String tagName = 'ul';
}

class LiNode extends Node {
  @override
  String tagName = 'li';
}

class ANode extends Node {
  @override
  String tagName = 'a';

  ANode({ String? href, Component? child, String? className }): super(child: child, className: className) {
    if (href != null) {
      _attributes['href'] = href;
    }
  }
}

class ButtonNode extends Node {
  @override
  String tagName = 'button';
  Function? onClick;

  ButtonNode({ this.onClick, Component? child, String? className }): super(child: child, className: className) {
    if (onClick != null) {
      _attributes['onclick'] = 'cl.call(this)';
      listenUser(id, 1, onClick!);
    }
  }
}

class PageComponent extends Node {
  String? title;
  @override
  String tagName = 'body';

  PageComponent(child, { this.title }): super(child: child);

  @override
  String render() {
    final titleTag = title != null ? '<title>$title</title>' : '';
    final body = child!.render();
    return '<!DOCTYPE html><html><head>$titleTag<script src="/web.js"></script></head><body id="$id">$body</body></html>';
  }
}
