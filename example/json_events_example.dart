import "dart:async";

import "package:json_events/json_events.dart";

Future<void> main() async {
  String jsonString = """
  {
    "compressionlevel": -1,
    "height": 32,
    "infinite": false,
    "layers": [
      {
        "id": 16,
        "image": "../images/background.jpg",
        "name": "Image Layer 1",
        "opacity": 1,
        "type": "imagelayer",
        "visible": true,
        "x": 0,
        "y": 0,
        "a": {
          "b": "1",
          "c": "2"
        }
      }
    ],
    "fields": [
      "16",
      "20",
      "32"
    ],
    "width": 32
  }
  """;

  Stream<JsonEvent> s =
      Stream.value(jsonString).transform(const JsonEventDecoder()).flatten();

  await for (JsonEvent je in s) {
    // ignore: avoid_print
    print("Event Type: ${je.type.name} Value: ${je.value}");
  }
}
