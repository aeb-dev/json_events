<p>
  <a title="Pub" href="https://pub.dev/packages/json_events" ><img src="https://img.shields.io/pub/v/json_events.svg?style=popout" /></a>
</p>

# json_events
A package for parsing large json files/objects. The package processes the json in a forward-only way and emits events based on the tokens it encounters.

# Parsing manually

From a `Stream`
```dart
Stream<List<int>> s = ...;

s.transform(const Utf8Decoder())
  .transform(const JsonEventDecoder())
  .flatten();

await for (JsonEvent je in s) {
  print("Event Type: ${je.type.name} Value: ${je.value}");
}
```

From a `String`
```dart
Stream<String> s = Stream.value(...);

s.transform(const JsonEventDecoder())
  .flatten();

await for (JsonEvent je in s) {
  print("Event Type: ${je.type.name} Value: ${je.value}");
}
```

# Using mixin
## For objects
```dart
class MyClass with JsonObjectTraverser {
  late int x;
  late List<MyClass> arr;
  late List<int> pArr;
  late List<List<int>> pNestedArray;
  String? text;

  @override
  Future<void> readJson(String key) async {
    switch (key) {
      case "x":
        x = await this.readPropertyJsonContinue<int>();
        break;
      case "text":
        y = await this.readPropertyJsonContinue<String?>();
        break;
      case "arr":
        arr = await this.readPropertyJsonContinue<MyClass>(creator: MyClass.new);
        break;
      case "pArr":
        pArr = await this.readArrayJsonContinue<int>().toList();
        break;
      case "pNestedArray":
        pNestedArray = await this.readNestedArrayJsonContinue<int>().toList();
        break;
    }
  }
}
```

Then call appropriate loader
```dart
MyClass mc = MyClass();
await mc.loadJson(streamIterator);
```

## For arrays that are represented as objects
```dart
class MyArrayClass with JsonArrayTraverser<MyClass> {
  @override
  FutureOr<MyClass> Function()? creator = MyClass.new; // or in constructor

  MyArrayClass() : super([]) {
    // creator = MyClass.new;
  }
}
```

Then call appropriate loader
```dart
MyArrayClass mc = MyArrayClass();
await mc.loadJsonFromStream(stream);
```

# Disclaimer
- Most of the code for the parsing is from [dart-sdk](https://github.com/dart-lang/sdk/blob/main/sdk/lib/_internal/vm/lib/convert_patch.dart)
- Inspired from [dart-json-stream-parser](https://github.com/llamadonica/dart-json-stream-parser)
- Test cases are copied from [JSONTestSuite](https://github.com/nst/JSONTestSuite)
