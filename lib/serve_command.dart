import 'dart:io';

import 'package:aldrin/server.dart';
import 'package:args/command_runner.dart';
import 'package:hotreloader/hotreloader.dart';

class ServeCommand extends Command {
  @override
  final name = 'serve';
  @override
  final description = 'Serve aldrin project.';

  @override
  void run() async {
    final hotreload = await HotReloader.create(
        onAfterReload: handleReload,
    );

    ProcessSignal.sigint.watch().listen((signal) {
      hotreload.stop();
      exit(0);
    });

    final port = int.parse('4200');
    final server = await startServer(port);
    print('Serving at http://${server.address.host}:${server.port}');
    print('Press Ctrl+C to stop.');
  }
}

void handleReload(AfterReloadContext context) {
  final list = context.reloadReports.keys.toList().map((k) => '${k.name}(${k.id})');
  print('Reloaded: ${list.join(', ')}');
  sendToUser('{ "e": 0 }');
}
