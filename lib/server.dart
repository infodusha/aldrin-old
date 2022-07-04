import 'dart:io';

import 'package:aldrin/connection_registry.dart';
import 'package:aldrin/definitions.dart';
import 'package:aldrin/router.dart';
import 'package:nanoid/nanoid.dart';

import 'context.dart';

final File webScriptFile = File('./web/out.js');
const String idCookieName = 'id';

ConnectionRegistry _connectionRegistry = ConnectionRegistry();

Future<HttpServer> startServer(InternetAddress address, int port) async {
  final String webScript = await webScriptFile.readAsString();
  final HttpServer server = await HttpServer.bind(address, port);
  server.listen((HttpRequest request) => _onRequest(request, webScript));
  return server;
}

void _onRequest(HttpRequest request, String webScript) {
  if (request.uri.path == '/_ws') {
    _attachWebSocket(request);
  } else if (request.uri.path == '/web.js') {
    request.response.headers.add('Content-Type', 'text/javascript');
    request.response.write(webScript);
    request.response.close();
  } else if (request.uri.path == '/') {
    Cookie idCookie = _createIdCookie();
    request.response.cookies.add(idCookie);
    request.response.headers.add('Content-Type', 'text/html');
    request.response.write(getRootRoute());
    request.response.close();
    Context(idCookie.value).run(_runInContext);
  } else {
    request.response.close();
  }
}

void _runInContext() {
  OnMountDef.init();
}

Future<void> _attachWebSocket(HttpRequest request) async {
  String id = _getId(request.cookies);
  WebSocket ws = await WebSocketTransformer.upgrade(request);
  _connectionRegistry.add(id, ws);
}

Cookie _createIdCookie() {
  Cookie cookie = Cookie(idCookieName, nanoid());
  cookie.httpOnly = true;
  return cookie;
}

String _getId(List<Cookie> cookies) {
  return cookies.firstWhere((c) => c.name == idCookieName).value;
}

