import 'dart:io';

import 'package:aldrin/bootstrap.dart';
import 'package:aldrin/server.dart';
import 'package:args/command_runner.dart';
import 'package:hotreloader/hotreloader.dart';
import 'package:intl/intl.dart';

import '../actions.dart';
import '../utils.dart';

class ServeCommand extends Command {
  @override
  final name = 'serve';
  @override
  final description = 'Serve aldrin project.';

  void _handleReload(AfterReloadContext context) async {
    String now = DateFormat('hh:mm:ss').format(DateTime.now());
    colorPrint('Reloaded at $now', '\x1B[32m');
    await boostrapRestart();
    EmitActions().reload();
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
    print('Serving at http://localhost:${server.port}');
    colorPrint('Press Ctrl+C to stop.\n', '\x1B[33m');
  }
}

