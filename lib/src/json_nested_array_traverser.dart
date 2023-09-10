import "dart:async";

import "package:meta/meta.dart";

import "../json_events.dart";
import "json_traverser.dart" as json_traverser;

/// A mixin for representing a nested array
mixin JsonNestedArrayTraverser<T extends List<dynamic>, E> on List<T>
    implements json_traverser.JsonTraverser {
  /// A delegate for creating type [E].
  /// For primitive types leave it null.
  @protected
  FutureOr<E> Function()? get creator => null;

  @internal
  @override
  FutureOr<void> loadJson(
    StreamIterator<JsonEvent> si,
  ) async {
    await for (T t in json_traverser.readNestedArrayJson<T, E>(
      si: si,
      creator: creator,
    )) {
      add(t);
    }
  }

  @protected
  @override
  FutureOr<void> postProcessJson() async {}
}
