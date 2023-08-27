import "../../json_events.dart";

/// Extensions for [Stream] of [Iterable] of [JsonEvent]s
extension StreamExtensions on Stream<Iterable<JsonEvent>> {
  /// Flattens a [Stream] of [Iterable] of [JsonEvent] to a [Stream] of
  /// of [JsonEvent]
  Stream<JsonEvent> flatten() => expand((Iterable<JsonEvent> values) => values);
}
