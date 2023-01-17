part of "json_event_decoder.dart";

/// A [_JsonListener] builds data objects from the parser events.
///
/// This is a simple stack-based object builder. It keeps the most recently
/// seen value in a variable, and uses it depending on the following event.
class _JsonListener {
  _JsonListener();

  /// Stack used to handle nested containers.
  ///
  /// The current container is pushed on the stack when a new one is
  /// started. If the container is a [Map], there is also a current [key]
  /// which is also stored on the stack.
  final List<Object?> stack = [];

  /// The most recently read value. */
  Object? value;

  bool hasValue = false;

  /// The most recently read value. */
  final List<JsonEvent> _chunkedEvents = [];

  void handleString(String value) {
    this.value = value;
    this.hasValue = true;
  }

  void handleNumber(num value) {
    this.value = value;
    this.hasValue = true;
  }

  // ignore: avoid_positional_boolean_parameters
  void handleBool(bool value) {
    this.value = value;
    this.hasValue = true;
  }

  void handleNull() {
    value = null;
    this.hasValue = true;
  }

  void beginObject() {
    _chunkedEvents.add(
      const JsonEvent(JsonEventType.beginObject),
    );
  }

  void propertyName() {
    _chunkedEvents.add(
      JsonEvent(
        JsonEventType.propertyName,
        value: value,
      ),
    );

    value = null;
    this.hasValue = false;
  }

  void propertyValue() {
    _chunkedEvents.add(
      JsonEvent(
        JsonEventType.propertyValue,
        value: value,
      ),
    );

    value = null;
    this.hasValue = false;
  }

  void endObject() {
    _chunkedEvents.add(
      const JsonEvent(JsonEventType.endObject),
    );
  }

  void beginArray() {
    _chunkedEvents.add(
      const JsonEvent(JsonEventType.beginArray),
    );
  }

  void arrayElement() {
    _chunkedEvents.add(
      JsonEvent(
        JsonEventType.arrayElement,
        value: value,
      ),
    );

    value = null;
    this.hasValue = false;
  }

  void endArray() {
    _chunkedEvents.add(
      const JsonEvent(JsonEventType.endArray),
    );
  }

  /// Read out the final result of parsing a JSON string.
  ///
  /// Must only be called when the entire input has been parsed.
  List<JsonEvent> get result => _chunkedEvents;
}
