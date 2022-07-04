import 'package:aldrin/router.dart';

import 'actions.dart';
import 'components/nodes.dart';

PageComponent Function()? _pageComponent;

Future<void> boostrap(PageComponent Function() pageComponent) async {
  _pageComponent = pageComponent;
  await _initActions();
  String html = pageComponent().render();
  registerRootRoute(html);
}

Future<void> _initActions() async {
  ExecuteActions executor = ExecuteActions();
  await executor.init();

  final emitter = EmitActions();
  await emitter.init();
}

Future<void> boostrapRestart() async {
  PageComponent Function()? pageComponent = _pageComponent;
  if (pageComponent == null) {
    throw Exception('Unable to bootstrap again');
  }
  String html = pageComponent().render();
  registerRootRoute(html);
}
