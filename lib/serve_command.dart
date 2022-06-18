import 'package:args/command_runner.dart';

class ServeCommand extends Command {
  @override
  final name = 'serve';
  @override
  final description = 'Serve aldrin project.';

  @override
  void run() {
    print('Serve aldrin project');
  }
}
