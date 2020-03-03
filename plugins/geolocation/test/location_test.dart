import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:location/location.dart';
import 'package:mockito/mockito.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannel methodChannel;
  MockEventChannel eventChannel;
  Location location;

  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    methodChannel = MethodChannel('lyokone/location');
    eventChannel = MockEventChannel();
    location = Location.private(methodChannel, eventChannel);

    methodChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      log.add(methodCall);
      switch (methodCall.method) {
        case "getLocation":
          return {
            "latitude": 48.8534,
            "longitude": 2.3488,
          };
        case "changeSettings":
          return 1;
        case "serviceEnabled":
          return 1;
        case "requestService":
          return 1;
        default:
          return '';
      }
    });

    log.clear();
  });

  group('Permission Status', () {
    test('getLocation should convert results correctly', () async {
      var receivedLocation = await location.getLocation();
      expect(receivedLocation.latitude, 48.8534);
      expect(receivedLocation.longitude, 2.3488);
    });

    test('getLocation should convert to string correctly', () async {
      var receivedLocation = await location.getLocation();
      expect(receivedLocation.toString(),
          "LocationData<lat: ${receivedLocation.latitude}, long: ${receivedLocation.longitude}>");
    });
  });

  test('changeSettings passes parameters correctly', () async {
    await location.changeSettings();
    expect(log, <Matcher>[
      isMethodCall('changeSettings', arguments: <String, dynamic>{
        "accuracy": LocationAccuracy.HIGH.index,
        "interval": 1000,
        "distanceFilter": 0
      }),
    ]);
  });

  group('Service Status', () {
    test('serviceEnabled should convert results correctly', () async {
      var result = await location.serviceEnabled();
      expect(result, true);
    });

    test('requestService should convert to string correctly', () async {
      var result = await location.requestService();
      expect(result, true);
    });
  });

  group('Permission Status', () {
    test('Should convert int to correct Permission Status', () async {
      methodChannel.setMockMethodCallHandler((MethodCall methodCall) async {
        return 0;
      });
      var receivedPermission = await location.hasPermission();
      expect(receivedPermission, PermissionStatus.DENIED);
      receivedPermission = await location.requestPermission();
      expect(receivedPermission, PermissionStatus.DENIED);

      methodChannel.setMockMethodCallHandler((MethodCall methodCall) async {
        return 1;
      });
      receivedPermission = await location.hasPermission();
      expect(receivedPermission, PermissionStatus.GRANTED);
      receivedPermission = await location.requestPermission();
      expect(receivedPermission, PermissionStatus.GRANTED);

      methodChannel.setMockMethodCallHandler((MethodCall methodCall) async {
        return 2;
      });
      receivedPermission = await location.hasPermission();
      expect(receivedPermission, PermissionStatus.DENIED_FOREVER);
      receivedPermission = await location.requestPermission();
      expect(receivedPermission, PermissionStatus.DENIED_FOREVER);
    });

    test('Should throw if other message is sent', () async {
      methodChannel.setMockMethodCallHandler((MethodCall methodCall) async {
        return 12;
      });
      try {
        await location.hasPermission();
      } on PlatformException catch (err) {
        expect(err.code, "UNKNOWN_NATIVE_MESSAGE");
      }
      try {
        await location.requestPermission();
      } on PlatformException catch (err) {
        expect(err.code, "UNKNOWN_NATIVE_MESSAGE");
      }
    });
  });

  group("Location Updates", () {
    StreamController<Map<String, double>> controller;

    setUp(() {
      controller = StreamController<Map<String, double>>();
      when(eventChannel.receiveBroadcastStream())
          .thenAnswer((Invocation invoke) => controller.stream);
    });

    tearDown(() {
      controller.close();
    });

    test('call receiveBrodcastStream once', () {
      location.onLocationChanged();
      location.onLocationChanged();
      location.onLocationChanged();
      verify(eventChannel.receiveBroadcastStream()).called(1);
    });

    test('should receive values', () async {
      final StreamQueue<LocationData> queue =
          StreamQueue<LocationData>(location.onLocationChanged());

      controller.add({
        "latitude": 48.8534,
        "longitude": 2.3488,
      });
      LocationData data = await queue.next;
      expect(data.latitude, 48.8534);
      expect(data.longitude, 2.3488);

      controller.add({
        "latitude": 42.8534,
        "longitude": 23.3488,
      });
      data = await queue.next;
      expect(data.latitude, 42.8534);
      expect(data.longitude, 23.3488);
    });
  });
}

class MockEventChannel extends Mock implements EventChannel {}
