import "dart:async";
import "dart:convert";
import "dart:io";

import "package:json_events/json_events.dart";

Future<void> main() async {
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
}
