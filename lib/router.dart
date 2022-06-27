String? _rootRoute;

registerRootRoute(String html) {
  _rootRoute = html;
}

String getRootRoute() {
  String? rootRoute = _rootRoute;
  if (rootRoute == null) {
    throw Exception('Root route is not registered');
  }
  return rootRoute;
}
