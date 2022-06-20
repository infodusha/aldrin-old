class StateDef<T> {
  Function? _callback;
  T _value;

  T get value => _value;
  set value(T value) {
    if (_value == value) {
      return;
    }
    _value = value;
    if (_callback != null) {
      _callback!(value);
    }
  }

  StateDef(this._value);

  onChange(void Function (T value) callback) {
    _callback = callback;
  }
}
