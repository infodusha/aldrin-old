import 'dart:async';
import 'dart:io';

import 'package:aldrin/definitions.dart';

import 'context.dart';

class ConnectionRegistry {
  static final ConnectionRegistry _instance = ConnectionRegistry._init();

  factory ConnectionRegistry() => _instance;

  final List<_Connection> _connections = [];
  final StreamController<String> _eventsController = StreamController.broadcast();
  late Stream<String> events;

  ConnectionRegistry._init() {
    events = _eventsController.stream;
  }

  void _closed(_Connection connection) {
    _connections.remove(connection);
  }

  void add(String id, WebSocket ws) {
    _connections.add(_Connection(id, ws, _closed, _eventsController));
  }
  
  void send(String id, String message) {
    _connections.where((c) => c.id == id).forEach((c) => c.send(message));
  }

  void broadcast(String message) {
    for (_Connection connection in _connections) {
      connection.send(message);
    }
  }
}

class _Connection {
  final String id;
  final WebSocket _ws;
  final void Function(_Connection connection) _closed;
  final StreamController<String> _eventsController;

  void _onData(dynamic data) {
    runInContext(getContext(id), () {
      _eventsController.add(data);
    });
  }

  void _onDone() {
    runInContext(getContext(id), () {
      OnUnMountDef.run();
    });
    _closed(this);
    removeContext(id);
  }

  _Connection(this.id, this._ws, this._closed, this._eventsController) {
    _ws.listen(_onData, onDone: _onDone);
  }

  send(String message) {
    _ws.add(message);
  }
}
