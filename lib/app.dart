import 'package:aldrin/components/nodes.dart';
import 'package:aldrin/components/components.dart';
import 'package:aldrin/components/elements.dart';
import 'package:aldrin/definitions.dart';

PageComponent appComponent() {
  final visibleState = StateDef(false);
  final visibleState1 = StateDef(true);

  buttonClick() {
    visibleState.value = !visibleState.value;
  }

  buttonClick1() {
    visibleState1.value = !visibleState1.value;
  }

  return PageComponent(Fragment([
    DivNode(child: TextElement('Test page')),
    IfElement(visibleState1, DivNode(child: TextElement('Extra data 1'))),
    DivNode(child: ButtonNode(
      child: TextElement('Click me 1'),
      onClick: buttonClick1,
    )),
    DivNode(child: ButtonNode(
      child: TextElement('Click me'),
      onClick: buttonClick
    )),
    IfElement(visibleState, Fragment([
      DivNode(child: TextElement('TEST1')),
      DivNode(child: TextElement('TEST2')),
    ])),
    testComponent(),
  ]));
}

Component testComponent() {
  return DivNode(child: Fragment([
    TextElement('Test component'),
    ANode(child: TextElement('Go to Google'), href: 'https://google.com'),
  ]));
}


String bootstrap(PageComponent Function() pageComponent) {
  return pageComponent().render();
}
