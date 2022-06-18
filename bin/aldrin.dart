import 'dart:io';
import 'package:args/command_runner.dart';

import 'package:aldrin/new_command.dart';
import 'package:aldrin/serve_command.dart';

void main(List<String> args) {
  var runner = CommandRunner("aldrin", "Single Page Applications running on the server side.")
    ..addCommand(NewCommand())
    ..addCommand(ServeCommand());

  runner.run(args).catchError((error) {
    if (error is !UsageException) throw error;
    print(error);
    exit(64);
  });
}
