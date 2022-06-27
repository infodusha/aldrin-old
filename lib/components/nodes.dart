import 'package:aldrin/actions.dart';
import 'package:aldrin/components/components.dart';
import 'package:aldrin/definitions.dart';
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
    String attributes = _attributes.entries.map((entry) {
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

  final ExecuteActions _executor = ExecuteActions();

  ButtonNode({ final void Function()? onClick, Component? child, String? className }): super(child: child, className: className) {
    if (onClick != null) {
      _attributes['onclick'] = 'cl(this)';
      OnMountDef(() {
        _executor.onClick(id).listen((_) {
          onClick();
        });
      });
    }
  }
}

class PageComponent extends Node {
  String? title;
  @override
  String tagName = 'body'; // Not used in any way
  final Component _child;

  PageComponent(this._child, { this.title }): super(child: _child);

  @override
  String render() {
    String titleTag = title != null ? '<title>$title</title>' : '';
    String body = _child.render();
    return '<!DOCTYPE html><html><head>$titleTag<script src="/web.js"></script></head><body id="$id">$body</body></html>';
  }
}
