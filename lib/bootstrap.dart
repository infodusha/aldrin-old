import 'package:aldrin/router.dart';

import 'actions.dart';
import 'components/nodes.dart';

Future<void> boostrap(PageComponent Function() pageComponent) async {
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
