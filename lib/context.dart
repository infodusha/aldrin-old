import 'dart:async';

import 'definitions.dart';

final List<Context> _allContexts = [];

class Context {
  static Context get current  => _getCurrentContext();
  static bool get hasCurrent => Zone.current[#context] != null;

  final String id;
  final List<StateDef> states = [];

  Context(this.id);
}

Context _getCurrentContext() {
  Context ? context = Zone.current[#context];
  if (context == null) {
    throw Exception('Context is not set');
  }
  return context;
}

void removeContext(String connectionId) {
  _allContexts.remove(getContext(connectionId));
}

Context getContext(String connectionId) {
  return _allContexts.firstWhere((c) => c.id == connectionId);
}

Context createContext(String connectionId) {
  Context context = Context(connectionId);
  _allContexts.add(context);
  return context;
}

void runInContext(Context context, void Function() fn) {
  runZoned(fn, zoneValues: { #context: context });
}
