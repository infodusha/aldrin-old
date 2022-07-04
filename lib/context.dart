import 'dart:async';

import 'context_data.dart';

final List<Context> _allContexts = [];

class Context {
  static Context get current  => _getCurrentContext();
  static bool get hasCurrent => Zone.current[#context] != null;

  static Context _getCurrentContext() {
    Context ? context = Zone.current[#context];
    if (context == null) {
      throw Exception('Context is not set');
    }
    return context;
  }

  static Context getById(String id) {
    return _allContexts.firstWhere((c) => c.id == id);
  }

  static void removeById(String id) {
    _allContexts.remove(getById(id));
  }

  final String id;
  final List<ContextBox<dynamic>> boxes = [];

  Context(this.id) {
    _allContexts.add(this);
  }

  void run(void Function() fn) {
    runZoned(fn, zoneValues: { #context: this });
  }
}

