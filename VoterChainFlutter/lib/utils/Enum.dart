abstract class Enum<T> {
  final T _value;
  
  const Enum(this._value);
  
  bool operator ==(operand) => _value == operand._value;
  
  int get hashCode => super.hashCode;

  String toString() => _value.toString();
}