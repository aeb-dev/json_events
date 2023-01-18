import "dart:async";

import "package:meta/meta.dart";

import "../json_events.dart";

/// A base mixin for json values
mixin JsonTraverser {
  /// The iterator to be used while parsing
  @protected
  late StreamIterator<JsonEvent> sij;

  /// Starts the loading of the json value to the correspoding
  /// json value from the iterator
  @internal
  FutureOr<void> loadJson(StreamIterator<JsonEvent> si);

  /// This function can be used to add logic after the json value is parsed
  /// This is called after [loadJson] is finished. It is safe to leave it
  /// as empty function body
  @protected
  FutureOr<void> postProcessJson();
}

/// It is almost same with the [readPropertyJsonContinue].
/// The difference is that this function assumes the iterator
/// has not moved yet. So it calls [StreamIterator.moveNext]
/// then calls [readPropertyJsonContinue]
Future<T> readPropertyJson<T>({
  required StreamIterator<JsonEvent> si,
  T? defaultValue,
}) async {
  await si.moveNext();

  T t = await readPropertyJsonContinue(
    si: si,
    defaultValue: defaultValue,
  );
  return t;
}

/// Reads the current value as a json value from the iterator
Future<T> readPropertyJsonContinue<T>({
  required StreamIterator<JsonEvent> si,
  T? defaultValue,
}) async {
  num toNum(num value) {
    if (1.1 is T) {
      return value.toDouble();
    } else {
      return value.toInt();
    }
  }

  assert(si.current.type == JsonEventType.propertyValue);

  dynamic value = si.current.value;

  if (value == null) {
    if (defaultValue != null) {
      return defaultValue;
    }

    return null as T;
  }

  if (value is num) {
    value = toNum(value);
  }

  return value as T;
}

/// It is almost same with the [readCustomObjectJsonContinue].
/// The difference is that this function assumes the iterator
/// has not moved yet. So it calls [StreamIterator.moveNext]
/// then calls [readCustomObjectJsonContinue]
/// You can use this function for parsing objects that
/// you do not know the type before parsing. For example,
/// polymorphism based on field or $type fields
Future<void> readCustomObjectJson({
  required StreamIterator<JsonEvent> si,
  required FutureOr<void> Function(String key) readJson,
  FutureOr<void> Function()? postProcessJson,
}) async {
  await si.moveNext();

  await readCustomObjectJsonContinue(
    si: si,
    readJson: readJson,
    postProcessJson: postProcessJson,
  );
}

/// Reads the current value as an object from the iterator
Future<void> readCustomObjectJsonContinue({
  required StreamIterator<JsonEvent> si,
  required FutureOr<void> Function(String key) readJson,
  FutureOr<void> Function()? postProcessJson,
}) async {
  assert(si.current.type == JsonEventType.beginObject);

  late String key;
  while (await si.moveNext()) {
    if (si.current.type == JsonEventType.endObject) {
      break;
    }

    if (si.current.type == JsonEventType.propertyName) {
      key = si.current.value as String;

      continue;
    }

    if (si.current.type == JsonEventType.propertyValue &&
        si.current.value != null) {
      await readJson(key);

      continue;
    }

    if (si.current.type == JsonEventType.beginObject ||
        si.current.type == JsonEventType.beginArray) {
      JsonEvent oldEvent = si.current;
      await readJson(key);

      if (oldEvent == si.current) {
        await _readUnknown(
          si: si,
        );
      }

      continue;
    }
  }

  await postProcessJson?.call();
}

/// It is almost same with the [readObjectJsonContinue].
/// The difference is that this function assumes the iterator
/// has not moved yet. So it calls [StreamIterator.moveNext]
/// then calls [readObjectJsonContinue]
Future<T> readObjectJson<T extends JsonObjectTraverser>({
  required StreamIterator<JsonEvent> si,
  required FutureOr<T> Function() creator,
}) async {
  await si.moveNext();

  T t = await readObjectJsonContinue(
    si: si,
    creator: creator,
  );

  return t;
}

/// Reads the current value as an object from the iterator
Future<T> readObjectJsonContinue<T extends JsonObjectTraverser>({
  required StreamIterator<JsonEvent> si,
  required FutureOr<T> Function() creator,
}) async {
  assert(si.current.type == JsonEventType.beginObject);

  T t = await creator();
  t.sij = si;

  await readCustomObjectJsonContinue(
    si: si,
    readJson: t.readJson,
    postProcessJson: t.postProcessJson,
  );

  return t;
}

/// Reads the current value as an array from the iterator
/// It is almost same with the [readArrayJsonContinue].
/// The difference is that this function assumes the iterator
/// has not moved yet. So it calls [StreamIterator.moveNext]
/// then calls [readArrayJsonContinue]
Stream<T> readArrayJson<T>({
  required StreamIterator<JsonEvent> si,
  FutureOr<T> Function()? creator,
  bool callLoader = true,
}) async* {
  await si.moveNext();

  yield* readArrayJsonContinue(
    si: si,
    creator: creator,
    callLoader: callLoader,
  );
}

/// Reads the current value as an array from the iterator
Stream<T> readArrayJsonContinue<T>({
  required StreamIterator<JsonEvent> si,
  FutureOr<T> Function()? creator,
  bool callLoader = true,
}) async* {
  assert(si.current.type == JsonEventType.beginArray);

  while (await si.moveNext()) {
    if (si.current.type == JsonEventType.endArray) {
      break;
    }

    if (si.current.type == JsonEventType.beginObject) {
      assert(creator != null);

      T t;
      if (callLoader) {
        var _creator = creator as FutureOr<JsonObjectTraverser> Function();
        t = await readObjectJsonContinue<JsonObjectTraverser>(
          si: si,
          creator: _creator,
        ) as T;
      } else {
        t = await creator!();
      }

      yield t;

      await si.moveNext();
      assert(si.current.type == JsonEventType.arrayElement);
      continue;
    }

    if (si.current.type == JsonEventType.arrayElement) {
      T t = si.current.value as T;
      yield t;
      continue;
    }
  }
}

/// It is almost same with the [readNestedArrayJsonContinue].
/// The difference is that this function assumes the iterator
/// has not moved yet. So it calls [StreamIterator.moveNext]
/// then calls [readNestedArrayJsonContinue]
Stream<T> readNestedArrayJson<T extends List<dynamic>, E>({
  required StreamIterator<JsonEvent> si,
  FutureOr<E> Function()? creator,
  bool callLoader = true,
}) async* {
  await si.moveNext();

  yield* readNestedArrayJsonContinue<T, E>(
    si: si,
    creator: creator,
    callLoader: callLoader,
  );
}

/// Reads the current value as a nested array from the iterator
Stream<T> readNestedArrayJsonContinue<T extends List<dynamic>, E>({
  required StreamIterator<JsonEvent> si,
  FutureOr<E> Function()? creator,
  bool callLoader = true,
}) async* {
  assert(si.current.type == JsonEventType.beginArray);

  while (await si.moveNext()) {
    if (si.current.type == JsonEventType.endArray) {
      break;
    }

    if (si.current.type == JsonEventType.beginArray) {
      List<E> le = <E>[];
      if (le is T) {
        await for (E e in readArrayJsonContinue(
          si: si,
          creator: creator,
          callLoader: callLoader,
        )) {
          le.add(e);
        }

        yield le as T;
      }

      List<List<E>> lle = <List<E>>[];
      if (lle is T) {
        await for (List<E> es in readNestedArrayJsonContinue<List<E>, E>(
          si: si,
          creator: creator,
          callLoader: callLoader,
        )) {
          lle.add(es);
        }

        yield lle as T;
      }

      List<List<List<E>>> llle = <List<List<E>>>[];
      if (llle is T) {
        await for (List<List<E>> es
            in readNestedArrayJsonContinue<List<List<E>>, E>(
          si: si,
          creator: creator,
          callLoader: callLoader,
        )) {
          llle.add(es);
        }

        yield llle as T;
      }

      await si.moveNext();
      assert(si.current.type == JsonEventType.arrayElement);
      continue;
    }
  }
}

/// Skips the current value if the caller did not handle it
/// with [JsonObjectTraverser.readJson]
Future<void> _readUnknown({
  required StreamIterator<JsonEvent> si,
}) async {
  if (si.current.type == JsonEventType.beginObject) {
    int beginObjectCount = 1;
    do {
      await si.moveNext();
      if (si.current.type == JsonEventType.beginObject) {
        beginObjectCount += 1;

        continue;
      }

      if (si.current.type == JsonEventType.endObject) {
        beginObjectCount -= 1;

        continue;
      }
    } while (
        si.current.type != JsonEventType.endObject || beginObjectCount != 0);
  }

  if (si.current.type == JsonEventType.beginArray) {
    int beginArrayCount = 1;
    do {
      await si.moveNext();
      if (si.current.type == JsonEventType.beginArray) {
        beginArrayCount += 1;

        continue;
      }

      if (si.current.type == JsonEventType.endArray) {
        beginArrayCount -= 1;

        continue;
      }
    } while (si.current.type != JsonEventType.endArray || beginArrayCount != 0);
  }
}
