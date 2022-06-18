import 'package:args/command_runner.dart';

class NewCommand extends Command {
  @override
  final name = 'new';
  @override
  final description = 'Create new aldrin project.';
  @override
  String usage = '''
Create new aldrin project.

Usage: aldrin new <project_name> [arguments]
-h, --help    Print this usage information.

Run "aldrin help" to see global options.
''';

  @override
  void run() {
    print('Creating new aldrin project called ${argResults?.rest}...');
  }
}
