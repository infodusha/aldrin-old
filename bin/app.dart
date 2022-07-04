import 'package:aldrin/components/nodes.dart';
import 'package:aldrin/components/components.dart';
import 'package:aldrin/components/elements.dart';
import 'package:aldrin/definitions.dart';

PageComponent appComponent() {
  final countState = StateDef(-1);
  final visibleState = StateDef(true);

  void countClick() {
    countState.value++;
  }

  void visibleClick() {
    visibleState.value = !visibleState.value;
  }

  return PageComponent(Fragment([
    DivNode(child: TextElement('Test page')),
    ifComponent(visibleState),
    DivNode(child: ButtonNode(
      child: TextElement('Toggle visible'),
      onClick: visibleClick,
    )),
    DivNode(child: ViewElement(() => TextElement(countState.value.toString()))),
    DivNode(child: ButtonNode(
      child: TextElement('Add count'),
      onClick: countClick
    )),
    IfElement(() => visibleState.value && countState.value > 0 && countState.value < 4, Fragment([
      DivNode(child: TextElement('TEST1')),
      DivNode(child: TextElement('TEST2')),
    ])),
    linkComponent(),
  ]));
}

Component ifComponent(StateDef<bool> visibleState) {
  return IfElement(() => visibleState.value, DivNode(child: Fragment([
    TextElement('Extra data 1 - 0'),
    TextElement('Extra data 1 - 1')
  ])), elseChild: TextElement('Else data 2'));
}

Component linkComponent() {
  OnMountDef(() {
    print('Link component mounted');
  });

  OnUnMountDef(() {
    print('Link component unmounted');
  });

  return DivNode(child: ANode(child: TextElement('Go to Google'), href: 'https://google.com'));
}
