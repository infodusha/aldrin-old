import 'dart:io';

import 'package:aldrin/server.dart';
import 'package:args/command_runner.dart';

class StartCommand extends Command {
  @override
  final name = 'start';
  @override
  final description = 'Start aldrin project.';

  final Future<void> Function() _main;
  StartCommand(this._main);

  @override
  void run() async {
    await _main();
    int port = int.parse('8080');
    HttpServer server = await startServer(InternetAddress.anyIPv4, port);
    print('Serving at http://${server.address.host}:${server.port}');
  }
}

