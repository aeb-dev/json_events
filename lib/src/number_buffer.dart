// ignore_for_file: parameter_assignments

part of "json_event_decoder.dart";

/// Buffer holding parts of a numeral.
///
/// The buffer contains the characters of a JSON number.
/// These are all ASCII, so an [Uint8List] is used as backing store.
///
/// This buffer is used when a JSON number is split between separate chunks.
///
class _NumberBuffer {
  static const int minCapacity = 16;
  static const int defaultOverhead = 5;
  Uint8List list;
  int length = 0;
  _NumberBuffer(int initialCapacity)
      : list = Uint8List(_initialCapacity(initialCapacity));

  int get capacity => list.length;

  // Pick an initial capacity greater than the first part's size.
  // The typical use case has two parts, this is the attempt at
  // guessing the size of the second part without overdoing it.
  // The default estimate of the second part is [defaultOverhead],
  // then round to multiplum of four, and return the result,
  // or [minCapacity] if that is greater.
  static int _initialCapacity(int minCapacity) {
    minCapacity += defaultOverhead;
    if (minCapacity < _NumberBuffer.minCapacity) {
      return _NumberBuffer.minCapacity;
    }
    return (minCapacity + 3) & ~3; // Round to multiple of four.
  }

  // Grows to the exact size asked for.
  void ensureCapacity(int newCapacity) {
    Uint8List list = this.list;
    if (newCapacity <= list.length) {
      return;
    }
    Uint8List newList = Uint8List(newCapacity)
      ..setRange(0, list.length, list, 0);
    this.list = newList;
  }

  String getString() {
    String result = String.fromCharCodes(list, 0, length);
    return result;
  }

  // TODO(lrn): See if parsing of numbers can be abstracted to something
  // not only working on strings, but also on char-code lists, without lossing
  // performance.
  num parseNum() => num.parse(getString());
  double parseDouble() => double.parse(getString());
}
