import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:mirrors';

import 'package:aldrin/connection_registry.dart';
import 'package:aldrin/context.dart';

abstract class _Actions {
  bool isEmitter;
  late List<dynamic> _methodNames;

  _Actions({ required this.isEmitter });

  Future<void> init() async {
    String fileName = isEmitter ? './on_client_actions.json' : './on_server_actions.json';
    String structureStr = await File(fileName).readAsString();
    _methodNames = jsonDecode(structureStr);
    _checkStructure();
  }

  int getAction(String methodName) {
    if (!_methodNames.contains(methodName)) {
      throw Exception('Unknown method name: $methodName');
    }
    return _methodNames.indexOf(methodName);
  }
  
  void callAction(int index, List<dynamic> args) {
    String methodName =  _methodNames.elementAt(index);
    ClassMirror classMirror = reflect(this).type;
    Symbol method = classMirror.instanceMembers.keys.firstWhere((key) => MirrorSystem.getName(key) == methodName);
    reflect(this).invoke(method, args);
  }

  void _checkStructure() {
    for (final method in _methodNames) {
      ClassMirror classMirror = reflect(this).type;
      Iterable<String> methodNames = classMirror.instanceMembers.keys.map((key) => MirrorSystem.getName(key));
      if (!methodNames.contains(method)) {
        String name = MirrorSystem.getName(classMirror.simpleName);
        throw Exception('Method $method is not defined in $name');
      }
    }
  }
}

class EmitActions extends _Actions {
  static final EmitActions _instance = EmitActions._init();

  factory EmitActions() => _instance;

  EmitActions._init(): super(isEmitter: true);

  final ConnectionRegistry _connectionRegistry = ConnectionRegistry();

  String _encode(List<dynamic> args) {
    return jsonEncode(args);
  }

  String _safeQuoteHtml(String html) {
    return html.replaceAll('"', '\\"');
  }

  void reload() {
    String act = _encode([getAction('reload')]);
    _connectionRegistry.broadcast(act);
  }

  void createElement(String id, int index, String html) {
    String act = _encode([getAction('createElement'), id, index, _safeQuoteHtml(html)]);
    _connectionRegistry.send(Context.current.id, act);
  }

  void removeElement(String id, int index, int l) {
    String act = _encode([getAction('removeElement'), id, index, l]);
    _connectionRegistry.send(Context.current.id, act);
  }

  void replaceElement(String id, int index, String html) {
    String act = _encode([getAction('replaceElement'), id, index, _safeQuoteHtml(html)]);
    _connectionRegistry.send(Context.current.id, act);
  }
}

class ExecuteActions extends _Actions {
  static final ExecuteActions _instance = ExecuteActions._init();

  factory ExecuteActions() => _instance;

  final ConnectionRegistry _connectionRegistry = ConnectionRegistry();
  final StreamController<String> _clickController = StreamController.broadcast();

  ExecuteActions._init(): super(isEmitter: false) {
    _connectionRegistry.events.listen((String message) {
      List<dynamic> args = jsonDecode(message);
      callAction(args[0], args.sublist(1));
    });
  }

  void connected() {
    print('Connected');
  }

  void click(String id) {
    _clickController.add(id);
  }

  Stream<void> onClick(String id) {
    Context context = Context.current;
    return _clickController.stream.where((sId) => sId == id && Context.current.id == context.id);
  }
}
