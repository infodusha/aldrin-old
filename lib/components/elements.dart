import 'package:aldrin/components/components.dart';
import 'package:aldrin/definitions.dart';
import 'package:aldrin/components/nodes.dart';
import 'package:aldrin/server.dart';

class IfElement extends Component {
  StateDef condition;
  late String childRender;
  String? elseChildRender;

  IfElement(this.condition, Component child, { Component? elseChild }) {
    child.parent = this;
    childRender = child.render();
    elseChildRender = elseChild?.render();

    condition.onChange((value) {
      Node parentNode = getParent();
      Fragment parentFragment = getParent();
      final i = parentFragment.getChildIndex(this);

      if (value) {
        final e = elseChild != null ? 3 : 1;
        sendToUser('{ "e": $e, "id": "${parentNode.id}", "c": "${childRender.replaceAll('"', '\\"')}", "i": $i }');
      } else {
        if (elseChildRender != null) {
          sendToUser('{ "e": 3, "id": "${parentNode.id}", "c": "${elseChildRender!.replaceAll('"', '\\"')}", "i": $i }');
        } else {
          final l = child is Fragment ? child.children.length : 1;
          sendToUser('{ "e": 2, "id": "${parentNode.id}", "i": $i, "l": "$l" }');
        }
      }
    });
  }

  @override
  String render() {
    if (condition.value) {
      return childRender;
    } else {
      return elseChildRender ?? '';
    }
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
