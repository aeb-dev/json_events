/// An event correspoding to the item in a json
class JsonEvent {
  /// Type of the event
  final JsonEventType type;

  /// Value of the event if there is one
  final dynamic value;

  /// Create an event from the give type and value
  const JsonEvent(this.type, {this.value});
}

/// Type of events that can be dispatched
enum JsonEventType {
  /// marks the beginning of an array value
  beginArray,

  /// marks the beginning of an object value
  beginObject,

  /// marks the end of an array value
  endArray,

  /// marks the end of an object value
  endObject,

  /// marks the end of an element in an array
  arrayElement,

  /// marks the name of property
  propertyName,

  /// marks the value of the property
  /// Value will be null for if the
  /// property is not a primitive type
  propertyValue,
}
