import "dart:async";

import "package:meta/meta.dart";

import "../json_events.dart";
import "json_traverser.dart" as json_traverser;

/// A mixin for reperesenting an array
mixin JsonArrayTraverser<T> on List<T> implements json_traverser.JsonTraverser {
  /// A delegate for creating type [T].
  /// For primitive types leave it null.
  @protected
  FutureOr<T> Function()? get creator => null;

  @internal
  @override
  FutureOr<void> loadJson(StreamIterator<JsonEvent> si) async {
    await for (T t in json_traverser.readArrayJson(
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
