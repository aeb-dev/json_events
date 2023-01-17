import "dart:async";

import "package:meta/meta.dart";

import "../json_events.dart";
import "json_traverser.dart" as json_traverser;

/// A mixin for reperesenting an object
mixin JsonObjectTraverser implements json_traverser.JsonTraverser {
  @override
  late final StreamIterator<JsonEvent> sij;

  @internal
  @override
  Future<void> loadJson(StreamIterator<JsonEvent> si) async {
    await json_traverser.readObjectJson(
      si: si,
      creator: () => this,
    );
  }

  /// This function is called every time a new key is
  /// encountered. How the json is parsed should be
  /// implemented inside this function
  Future<void> readJson(String key);

  /// Reads the current value from the iterator
  @protected
  @nonVirtual
  Future<T> readPropertyJsonContinue<T>({
    T? defaultValue,
  }) =>
      json_traverser.readPropertyJsonContinue(
        si: sij,
        defaultValue: defaultValue,
      );

  /// Reads the current value as object from the iterator
  @protected
  @nonVirtual
  Future<T> readObjectJsonContinue<T extends JsonObjectTraverser>({
    required FutureOr<T> Function() creator,
  }) =>
      json_traverser.readObjectJsonContinue(
        si: sij,
        creator: creator,
      );

  /// Reads the current value as array from the iterator
  @protected
  @nonVirtual
  Stream<T> readArrayJsonContinue<T>({
    FutureOr<T> Function()? creator,
    bool callLoader = true,
  }) =>
      json_traverser.readArrayJsonContinue(
        si: sij,
        creator: creator,
        callLoader: callLoader,
      );

  /// Reads the current value as array from the iterator
  @protected
  @nonVirtual
  Stream<T> readNestedArrayJsonContinue<T extends List<dynamic>, E>({
    FutureOr<E> Function()? creator,
    bool callLoader = true,
  }) =>
      json_traverser.readNestedArrayJsonContinue<T, E>(
        si: sij,
        creator: creator,
        callLoader: callLoader,
      );

  @override
  Future<void> postProcessJson() async {}
}
