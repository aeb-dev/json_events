part of "json_event_decoder.dart";

/// Implements the chunked conversion from a JSON string to its corresponding
/// object.
///
/// The sink only creates one object, but its input can be chunked.
class _JsonStringDecoderSink extends StringConversionSinkBase {
  final _JsonStringParser _parser;
  final Sink<List<JsonEvent>> _sink;

  _JsonStringDecoderSink(this._sink) : _parser = _createParser();

  static _JsonStringParser _createParser() =>
      _JsonStringParser(_JsonListener());

  @override
  void addSlice(String chunk, int start, int end, bool isLast) {
    _parser.chunk = chunk;
    _parser.chunkEnd = end;
    _parser.parse(start);
    _sink.add(_parser.result);
    _parser.result.clear();
    if (isLast) {
      _parser.close();
    }
  }

  @override
  void close() {
    _parser.close();
    var decoded = _parser.result;
    _sink.add(decoded);
    _sink.close();
  }

  // ByteConversionSink asUtf8Sink(bool allowMalformed) {
  //   return new _JsonUtf8DecoderSink(_sink, allowMalformed);
  // }
}
