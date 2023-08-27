part of "json_event_decoder.dart";

/// Chunked JSON parser that parses [String] chunks.
class _JsonStringParser extends _ChunkedJsonParser<String> {
  @override
  String chunk = "";
  @override
  int chunkEnd = 0;

  _JsonStringParser(super.listener);

  @override
  int getChar(int position) => chunk.codeUnitAt(position);

  @override
  String getString(int start, int end, int bits) => chunk.substring(start, end);

  @override
  void beginString() {
    buffer = StringBuffer();
  }

  @override
  void addSliceToString(int start, int end) =>
      this.buffer as StringBuffer..write(chunk.substring(start, end));

  @override
  void addCharToString(int charCode) =>
      this.buffer as StringBuffer..writeCharCode(charCode);

  @override
  String endString() {
    StringBuffer buffer = this.buffer as StringBuffer;
    this.buffer = null;
    return buffer.toString();
  }

  @override
  void copyCharsToList(int start, int end, List<int> target, int offset) {
    int length = end - start;
    for (int i = 0; i < length; i++) {
      target[offset + i] = chunk.codeUnitAt(start + i);
    }
  }

  @override
  double parseDouble(int start, int end) =>
      double.parse(chunk.substring(start, end));
}
