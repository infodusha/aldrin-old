import 'dart:io';

import 'package:aldrin/server.dart';
import 'package:args/command_runner.dart';
import 'package:hotreloader/hotreloader.dart';

import '../actions.dart';

class ServeCommand extends Command {
  @override
  final name = 'serve';
  @override
  final description = 'Serve aldrin project.';

  void _handleReload(AfterReloadContext context) {
    Iterable<String> list = context.reloadReports.keys.toList().map((k) => '${k.name}(${k.id})');
    print('Reloaded: ${list.join(', ')}');
    EmitActions emitter = EmitActions();
    emitter.reload();
  }

  Future<void> _restartWithWmService() async {
    await Process.start(
        Platform.resolvedExecutable,
        ['run', '--enable-vm-service', './bin/aldrin.dart', name],
        mode: ProcessStartMode.inheritStdio
    );
  }

  final Future<void> Function() _main;
  ServeCommand(this._main);

  @override
  void run() async {
    try {
      HotReloader hr = await HotReloader.create(
        onAfterReload: _handleReload,
      );

      ProcessSignal.sigint.watch().listen((signal) {
        hr.stop();
        exit(0);
      });
    } on StateError {
      await _restartWithWmService();
      return;
    }


    await _main();
    int port = int.parse('4200');
    HttpServer server = await startServer(InternetAddress.loopbackIPv4, port);
    print('Serving at http://${server.address.host}:${server.port}');
    print('Press Ctrl+C to stop.');
  }
}

