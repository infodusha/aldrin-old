import 'dart:convert';
import 'dart:io';

import 'package:aldrin/app.dart';

WebSocket? globalWebSocket;

Future<HttpServer> startServer(int port) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);

  server.listen((request) {
    if (request.uri.path == '/ws') {
      attachWebSocket(request);
    } else if (request.uri.path == '/web.js') {
      request.response.headers.add('Content-Type', 'text/javascript');
      File file = File('./web/web.js');
      request.response.write(file.readAsStringSync());
      request.response.close();
    } else {
      request.response.headers.add('Content-Type', 'text/html');
      request.response.write(bootstrap(appComponent));
      request.response.close();
    }
  });

  return server;
}

JsonDecoder decoder = JsonDecoder();
final listeners = {};

Future<void> attachWebSocket(HttpRequest request) async {
  final websocket = await WebSocketTransformer.upgrade(request);

  websocket.listen((data) {
    final k = decoder.convert(data);
    final key = '${k['id']}:${k['e']}';
    if (listeners[key] != null) {
      listeners[key]();
    }
    print('WS: $data');
  });

  globalWebSocket = websocket;
}

void sendToUser(String message) {
  if (globalWebSocket != null) {
    globalWebSocket!.add(message);
  }
}

void listenUser(String id, int e, Function listener) {
  listeners['$id:$e'] = listener;
}
