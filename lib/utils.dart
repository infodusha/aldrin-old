void colorPrint(String str, String color) {
  print('$color$str\x1B[0m');
}

List<T> getListChange<T>(List<T> list, void Function() fn) {
  List<T> before = [...list];
  fn();
  if (before.length == list.length) {
    return [];
  }
  if (before.length > list.length) {
    return before.sublist(list.length);
  }
  return list.sublist(before.length);
}

class CallsDetector {
  // TODO
}
