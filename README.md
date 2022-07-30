# json_events
A package for parsing large json files/objects. The package processes the json in a forward-only way and emits events based on the tokens it encounters.
> ⚠️ **Currently there is no support for encoding**



# Usage
```dart
File file = File("./json.json");
Stream<JsonEvent> s = file
    .openRead()
    .transform(const Utf8Decoder())
    .transform(const JsonEventDecoder())
    .flatten();

await for (JsonEvent je in s) {
// ignore: avoid_print
print("Event Type: ${je.type.name} Value: ${je.value}");
}
```

# Disclaimer
- Most of the code for the parsing is from [dart-sdk](https://github.com/dart-lang/sdk/blob/main/sdk/lib/_internal/vm/lib/convert_patch.dart)
- Inspired from [dart-json-stream-parser](https://github.com/llamadonica/dart-json-stream-parser)