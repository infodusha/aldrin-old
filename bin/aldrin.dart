import 'dart:io';
import 'package:aldrin/cli/start.dart';
import 'package:args/command_runner.dart';

import 'package:aldrin/cli/new.dart';
import 'package:aldrin/cli/serve.dart';

import 'main.dart' as app;

void main(List<String> args) {
  CommandRunner runner = CommandRunner("aldrin", "Single Page Applications running on the server side.")
    ..addCommand(NewCommand())
    ..addCommand(ServeCommand(app.main))
    ..addCommand(StartCommand(app.main));

  runner.run(args).catchError((error) {
    if (error is !UsageException) throw error;
    print(error);
    exit(64);
  });
}
