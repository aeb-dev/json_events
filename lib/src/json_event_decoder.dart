// ignore_for_file: constant_identifier_names, unused_field

import "dart:convert";
import "dart:typed_data";

import "json_event.dart";

part "chunked_json_parser.dart";
part "json_listeneler.dart";
part "json_string_decoder_sink.dart";
part "json_string_parser.dart";
part "number_buffer.dart";

/// This class parses JSON strings and builds the corresponding events.
class JsonEventDecoder extends Converter<String, List<JsonEvent>> {
  /// Constructs a new JsonEventDecoder.
  const JsonEventDecoder();

  /// Converts the given JSON-string [input] to its corresponding object.
  ///
  /// Parsed JSON values are of the types [num], [String], [bool], [Null],
  /// [List]s of parsed JSON values or [Map]s from [String] to parsed JSON
  /// values.
  ///
  /// If `this` was initialized with a reviver, then the parsing operation
  /// invokes the reviver on every object or list property that has been parsed.
  /// The arguments are the property name ([String]) or list index ([int]), and
  /// the value is the parsed value. The return value of the reviver is used as
  /// the value of that property instead the parsed value.
  ///
  /// Throws [FormatException] if the input is not valid JSON text.
  @override
  List<JsonEvent> convert(String input) {
    _JsonListener listener = _JsonListener();
    var parser = _JsonStringParser(listener);
    parser.chunk = input;
    parser.chunkEnd = input.length;
    parser.parse(0);
    parser.close();
    return listener.result;
  }

  /// Starts a conversion from a chunked JSON string to its corresponding object.
  ///
  /// The output [sink] receives exactly one decoded element through `add`.
  @override
  StringConversionSink startChunkedConversion(Sink<List<JsonEvent>> sink) =>
      _JsonStringDecoderSink(sink);
}
