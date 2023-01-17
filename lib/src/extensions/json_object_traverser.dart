// import "dart:async";

// import "../json_event.dart";
// import "../json_object_traverser.dart";
// import "json_traverser.dart";

// /// Utility extensions to load json
// extension JsonObjectTraverserExtensions on JsonObjectTraverser {
//   /// Starts the loading of the json value to the correspoding
//   /// json value from the [jsonMap]
//   Future<void> loadJsonFromMap(Map<String, dynamic> jsonMap) async {
//     late Stream<JsonEvent> Function(Map<String, dynamic> jsonMap)
//         traverseJsonObject;
//     late Stream<JsonEvent> Function(List<dynamic> jsonArray) traverseJsonArray;

//     traverseJsonObject = (jsonMap) async* {
//       yield const JsonEvent(JsonEventType.beginObject);

//       for (MapEntry<String, dynamic> me in jsonMap.entries) {
//         yield JsonEvent(
//           JsonEventType.propertyName,
//           value: me.key,
//         );

//         if (me.value is List<dynamic>) {
//           yield* traverseJsonArray(me.value as List<dynamic>);
//           continue;
//         }

//         yield JsonEvent(
//           JsonEventType.propertyValue,
//           value: me.value,
//         );
//       }

//       yield const JsonEvent(JsonEventType.endObject);
//     };

//     traverseJsonArray = (jsonArray) async* {
//       yield const JsonEvent(JsonEventType.beginArray);

//       for (dynamic value in jsonArray) {
//         if (value is Map) {
//           yield* traverseJsonObject(value as Map<String, dynamic>);
//           yield const JsonEvent(JsonEventType.arrayElement);
//           continue;
//         }

//         if (value is List) {
//           yield* traverseJsonArray(value);
//           yield const JsonEvent(JsonEventType.arrayElement);
//           continue;
//         }

//         yield JsonEvent(JsonEventType.arrayElement, value: value);
//       }

//       yield const JsonEvent(JsonEventType.endArray);
//     };

//     Stream<JsonEvent> jsonEvents = traverseJsonObject(jsonMap);

//     await loadJsonFromStream(jsonEvents);
//   }
// }
