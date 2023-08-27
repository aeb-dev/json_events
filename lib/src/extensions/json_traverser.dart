import "dart:async";

import "../json_event.dart";
import "../json_event_decoder.dart";
import "../json_traverser.dart";
import "stream.dart";

/// Utility extensions to load json
extension JsonTraverserExtensions on JsonTraverser {
  /// Starts the loading of the json value to the correspoding
  /// json value from the [s]
  Future<void> loadJsonFromStream(Stream<JsonEvent> s) async {
    StreamIterator<JsonEvent> si = StreamIterator<JsonEvent>(s);
    await loadJson(si);
  }

  /// Starts the loading of the json value to the correspoding
  /// json value from the [s]
  Future<void> loadJsonFromStringStream(Stream<String> s) async {
    Stream<JsonEvent> eventStream =
        s.transform(const JsonEventDecoder()).flatten();
    await loadJsonFromStream(eventStream);
  }

  /// Starts the loading of the json value to the correspoding
  /// json value from the [json]
  Future<void> loadJsonFromString(String json) async {
    Stream<String> s = Stream<String>.value(json);
    await loadJsonFromStringStream(s);
  }
}
