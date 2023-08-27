import "dart:async";
import "dart:convert";
import "dart:io";

import "package:async/async.dart";
import "package:collection/collection.dart";
import "package:json_events/json_events.dart";
import "package:path/path.dart" as path;
import "package:test/test.dart";

Future<void> main() async {
  test("json event parsing", () async {
    String jsonString = """
    {
      "type": 2,
      "value": 3
    }
    """;
    _JsonEvent je = _JsonEvent();

    await expectLater(je.loadJsonFromString(jsonString), completes);
    expect(je.type, equals(JsonEventType.endArray));
    expect(je.value, equals(3));
  });

  Directory d1 = Directory.fromUri(Uri(path: "./test/cases/default"));
  Directory d2 = Directory.fromUri(Uri(path: "./test/cases/custom"));
  Stream<FileSystemEntity> files = StreamGroup.merge(
    <Stream<FileSystemEntity>>[
      d1.list(),
      d2.list(),
    ],
  );

  await for (FileSystemEntity fse in files) {
    String fileName = path.basename(fse.path);
    File file = File(fse.path);
    Stream<JsonEvent> actualEventStream = file
        .openRead()
        .transform(const Utf8Decoder(allowMalformed: true))
        .transform(const JsonEventDecoder())
        .flatten();

    // TODO: check whether jsonDecode throws error as well
    if (fileName.contains("i_string_UTF-16LE_with_BOM") ||
        fileName.contains("i_string_utf16BE_no_BOM") ||
        fileName.contains("i_string_utf16LE_no_BOM") ||
        fileName.startsWith("n")) {
      test(fileName, () async {
        await expectLater(actualEventStream.toList, throwsException);
      });

      continue;
    }

    if (fileName.startsWith("y") || fileName.startsWith("i")) {
      test(fileName, () async {
        File file = File("./test/cases/expected/$fileName");
        Stream<JsonEvent> expectedEventStream = file
            .openRead()
            .transform(const Utf8Decoder(allowMalformed: true))
            .transform(const JsonEventDecoder())
            .flatten();

        StreamIterator<JsonEvent> si =
            StreamIterator<JsonEvent>(expectedEventStream);

        List<JsonEvent> expectedEvents = await readArrayJson(
          si: si,
          creator: _JsonEvent.new,
        ).map((_JsonEvent event) => event.toJsonEvent()).toList();

        List<JsonEvent> actualEvents = await actualEventStream.toList();

        bool hasSameLength = expectedEvents.length == actualEvents.length;
        bool isEqual = IterableZip<JsonEvent>(
          <List<JsonEvent>>[
            expectedEvents,
            actualEvents,
          ],
        ).every((List<JsonEvent> x) => x.first.equals(x.last));

        expect(isEqual && hasSameLength, isTrue);
      });
      continue;
    }
  }

  test("json object traverser", () async {
    String jsonString = """
    {
      "x": 1,
      "y": 2,
      "u": 0,
      "obj": {
        "x": 1,
        "obj": {
          "x": 1,
          "y": 2
        },
        "y": 2
      },
      "primArr": [
        0, 1, 2
      ],
      "nPrimArr": [
        [0,1,2],
        [3,4,5]
      ],
      "z": 3
    }
    """;
    TestObject to = TestObject();

    await expectLater(to.loadJsonFromString(jsonString), completes);
    expect(to.x, equals(1));
    expect(to.y, equals(2));
    expect(to.obj, isNotNull);
    expect(to.obj!.x, equals(1));
    expect(to.obj!.y, equals(2));
    expect(to.obj!.obj!.x, equals(1));
    expect(to.obj!.obj!.y, equals(2));
    expect(to.z, equals(3));
    expect(to.primArr.length, equals(3));
    expect(to.primArr[0], equals(0));
    expect(to.primArr[1], equals(1));
    expect(to.primArr[2], equals(2));
    expect(to.nPrimArr.length, equals(2));
    expect(to.nPrimArr[0], equals(<int>[0, 1, 2]));
    expect(to.nPrimArr[1], equals(<int>[3, 4, 5]));
  });

  test("array traverser object", () async {
    String jsonString = """
    [
      {
        "x": 1,
        "y": 2,
        "u": 0,
        "obj": {
          "x": 1,
          "obj": {
            "x": 1,
            "y": 2
          },
          "y": 2
        },
        "primArr": [
          0, 1, 2
        ],
        "nPrimArr": [
          [0,1,2],
          [3,4,5]
        ],
        "z": 3
      },
      {
        "x": 2,
        "y": 3,
        "u": 0,
        "obj": {
          "x": 1,
          "obj": {
            "x": 1,
            "y": 2
          },
          "y": 2
        },
        "primArr": [
          0, 1, 2
        ],
        "nPrimArr": [
          [0,1,2],
          [3,4,5]
        ],
        "z": 3
      }
    ]
    """;
    TestObjectArray toa = TestObjectArray();

    await expectLater(toa.loadJsonFromString(jsonString), completes);
    expect(toa[0].x, equals(1));
    expect(toa[0].y, equals(2));
    expect(toa[0].obj, isNotNull);
    expect(toa[0].obj!.x, equals(1));
    expect(toa[0].obj!.y, equals(2));
    expect(toa[0].obj!.obj!.x, equals(1));
    expect(toa[0].obj!.obj!.y, equals(2));
    expect(toa[0].z, equals(3));
    expect(toa[0].primArr.length, equals(3));
    expect(toa[0].primArr[0], equals(0));
    expect(toa[0].primArr[1], equals(1));
    expect(toa[0].primArr[2], equals(2));
    expect(toa[0].nPrimArr.length, equals(2));
    expect(toa[0].nPrimArr[0], equals(<int>[0, 1, 2]));
    expect(toa[0].nPrimArr[1], equals(<int>[3, 4, 5]));

    expect(toa[1].x, equals(2));
    expect(toa[1].y, equals(3));
    expect(toa[1].obj, isNotNull);
    expect(toa[1].obj!.x, equals(1));
    expect(toa[1].obj!.y, equals(2));
    expect(toa[1].obj!.obj!.x, equals(1));
    expect(toa[1].obj!.obj!.y, equals(2));
    expect(toa[1].z, equals(3));
    expect(toa[1].primArr.length, equals(3));
    expect(toa[1].primArr[0], equals(0));
    expect(toa[1].primArr[1], equals(1));
    expect(toa[1].primArr[2], equals(2));
    expect(toa[1].nPrimArr.length, equals(2));
    expect(toa[1].nPrimArr[0], equals(<int>[0, 1, 2]));
    expect(toa[1].nPrimArr[1], equals(<int>[3, 4, 5]));
  });

  test("array traverser primitive", () async {
    String jsonString = """
    [1,2,3]
    """;
    TestPrimitiveArray toa = TestPrimitiveArray();

    await expectLater(toa.loadJsonFromString(jsonString), completes);
    expect(toa[0], equals(1));
    expect(toa[1], equals(2));
    expect(toa[2], equals(3));
  });

  test("nested array traverser object", () async {
    String jsonString = """
    [
      [{
        "x": 1,
        "y": 2,
        "u": 0,
        "obj": {
          "x": 1,
          "obj": {
            "x": 1,
            "y": 2
          },
          "y": 2
        },
        "primArr": [
          0, 1, 2
        ],
        "nPrimArr": [
          [0,1,2],
          [3,4,5]
        ],
        "z": 3
      }],
      [{
        "x": 2,
        "y": 3,
        "u": 0,
        "obj": {
          "x": 1,
          "obj": {
            "x": 1,
            "y": 2
          },
          "y": 2
        },
        "primArr": [
          0, 1, 2
        ],
        "nPrimArr": [
          [0,1,2],
          [3,4,5]
        ],
        "z": 3
      }]
    ]
    """;
    TestNestedObjectArray toa = TestNestedObjectArray();

    await expectLater(toa.loadJsonFromString(jsonString), completes);
    expect(toa[0][0].x, equals(1));
    expect(toa[0][0].y, equals(2));
    expect(toa[0][0].obj, isNotNull);
    expect(toa[0][0].obj!.x, equals(1));
    expect(toa[0][0].obj!.y, equals(2));
    expect(toa[0][0].obj!.obj!.x, equals(1));
    expect(toa[0][0].obj!.obj!.y, equals(2));
    expect(toa[0][0].z, equals(3));
    expect(toa[0][0].primArr.length, equals(3));
    expect(toa[0][0].primArr[0], equals(0));
    expect(toa[0][0].primArr[1], equals(1));
    expect(toa[0][0].primArr[2], equals(2));
    expect(toa[0][0].nPrimArr.length, equals(2));
    expect(toa[0][0].nPrimArr[0], equals(<int>[0, 1, 2]));
    expect(toa[0][0].nPrimArr[1], equals(<int>[3, 4, 5]));

    expect(toa[1][0].x, equals(2));
    expect(toa[1][0].y, equals(3));
    expect(toa[1][0].obj, isNotNull);
    expect(toa[1][0].obj!.x, equals(1));
    expect(toa[1][0].obj!.y, equals(2));
    expect(toa[1][0].obj!.obj!.x, equals(1));
    expect(toa[1][0].obj!.obj!.y, equals(2));
    expect(toa[1][0].z, equals(3));
    expect(toa[1][0].primArr.length, equals(3));
    expect(toa[1][0].primArr[0], equals(0));
    expect(toa[1][0].primArr[1], equals(1));
    expect(toa[1][0].primArr[2], equals(2));
    expect(toa[1][0].nPrimArr.length, equals(2));
    expect(toa[1][0].nPrimArr[0], equals(<int>[0, 1, 2]));
    expect(toa[1][0].nPrimArr[1], equals(<int>[3, 4, 5]));
  });

  test("nestedarray traverser primitive", () async {
    String jsonString = """
    [[1,2,3], [2,3,4]]
    """;
    TestNestedPrimitiveArray toa = TestNestedPrimitiveArray();

    await expectLater(toa.loadJsonFromString(jsonString), completes);
    expect(toa[0], equals(<int>[1, 2, 3]));
    expect(toa[1], equals(<int>[2, 3, 4]));
  });
}

class TestObject with JsonObjectTraverser {
  int? x;
  int? y;
  int? z;
  TestObject? obj;
  List<int> primArr = <int>[];
  List<List<int>> nPrimArr = <List<int>>[];

  @override
  Future<void> readJson(String key) async {
    switch (key) {
      case "x":
        x = await this.readPropertyJsonContinue<int?>();
      case "y":
        y = await this.readPropertyJsonContinue<int?>();
      case "z":
        z = await this.readPropertyJsonContinue<int?>();
      case "obj":
        obj = await this.readObjectJsonContinue(creator: TestObject.new);
      case "primArr":
        await for (int i in this.readArrayJsonContinue()) {
          primArr.add(i);
        }
      case "nPrimArr":
        await for (List<int> li
            in this.readNestedArrayJsonContinue<List<int>, int>()) {
          nPrimArr.add(li);
        }
    }
  }
}

class TestPrimitiveArray extends DelegatingList<int>
    with JsonArrayTraverser<int> {
  TestPrimitiveArray() : super(<int>[]);
}

class TestObjectArray extends DelegatingList<TestObject>
    with JsonArrayTraverser<TestObject> {
  TestObjectArray() : super(<TestObject>[]) {
    creator = TestObject.new;
  }
}

class TestNestedObjectArray extends DelegatingList<List<TestObject>>
    with JsonNestedArrayTraverser<List<TestObject>, TestObject> {
  TestNestedObjectArray() : super(<List<TestObject>>[]) {
    creator = TestObject.new;
  }
}

class TestNestedPrimitiveArray extends DelegatingList<List<int>>
    with JsonNestedArrayTraverser<List<int>, int> {
  TestNestedPrimitiveArray() : super(<List<int>>[]);
}

class _JsonEvent with JsonObjectTraverser {
  late JsonEventType type;

  dynamic value;

  @override
  Future<void> readJson(String key) async {
    switch (key) {
      case "type":
        int typeAsInt = await this.readPropertyJsonContinue<int>();
        type = JsonEventType.values[typeAsInt];
      case "value":
        value = await this.readPropertyJsonContinue<dynamic>();
    }
  }

  JsonEvent toJsonEvent() => JsonEvent(type, value: value);
}

extension on JsonEvent {
  bool equals(JsonEvent other) => type == other.type && value == other.value;
}
