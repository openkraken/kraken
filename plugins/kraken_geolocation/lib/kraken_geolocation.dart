import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show visibleForTesting;

/// The response object of [Location.getLocation] and [Location.onLocationChanged]
///
/// speedAccuracy cannot be provided on iOS and thus is always 0.
class LocationData {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double altitude;
  final double speed;
  final double speedAccuracy;
  final double altitudeAccuracy;
  final double heading;
  final double time;

  LocationData._(this.latitude, this.longitude, this.accuracy, this.altitude,
    this.speed, this.speedAccuracy, this.altitudeAccuracy, this.heading,
    this.time);

  factory LocationData.fromMap(Map<String, double> dataMap) {
    return LocationData._(
      dataMap['latitude'],
      dataMap['longitude'],
      dataMap['accuracy'],
      dataMap['altitude'],
      dataMap['speed'],
      dataMap['speed_accuracy'],
      dataMap['altitude_accuracy'],
      dataMap['heading'],
      dataMap['time'],
    );
  }

  @override
  String toString() {
    return "LocationData<lat: $latitude, long: $longitude>";
  }
}

/// Precision of the Location. A lower precision will provide a greater battery life
///
/// https://developers.google.com/android/reference/com/google/android/gms/location/LocationRequest
/// https://developer.apple.com/documentation/corelocation/cllocationaccuracy?language=objc
enum LocationAccuracy { POWERSAVE, LOW, BALANCED, HIGH, NAVIGATION }

// Status of a permission request to use location services.
enum PermissionStatus {
  /// The permission to use location services has been granted.
  GRANTED,
  // The permission to use location services has been denied by the user. May have been denied forever on iOS.
  DENIED,
  // The permission to use location services has been denied forever by the user. No dialog will be displayed on permission request.
  DENIED_FOREVER
}

class Location {
  /// Initializes the plugin and starts listening for potential platform events.
  factory Location() {
    if (_instance == null) {
      final MethodChannel methodChannel =
      const MethodChannel('lyokone/location');
      final EventChannel eventChannel =
      const EventChannel('lyokone/locationstream');
      _instance = Location.private(methodChannel, eventChannel);
    }
    return _instance;
  }

  /// This constructor is only used for testing and shouldn't be accessed by
  /// users of the plugin. It may break or change at any time.
  @visibleForTesting
  Location.private(this._methodChannel, this._eventChannel);

  static Location _instance;

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;

  Stream<LocationData> _onLocationChanged;

  /// Change settings of the location request.
  ///
  /// The `accuracy` argument is controlling the precision of the [LocationData].
  /// The `interval` and `distanceFilter` are controlling how often a new location is sent
  /// through [onLocationChanged].
  Future<bool> changeSettings(
    {LocationAccuracy accuracy = LocationAccuracy.HIGH,
      int interval = 1000,
      double distanceFilter = 0}) =>
    _methodChannel.invokeMethod('changeSettings', {
      "accuracy": accuracy.index,
      "interval": interval,
      "distanceFilter": distanceFilter
    }).then((result) => result == 1);

  /// Gets the current location of the user.
  /// Returns a [LocationData] object.
  ///
  /// Throws an error if the app has no permission to access location.
  Future<LocationData> getLocation() async {
    Map<String, double> resultMap =
    (await _methodChannel.invokeMethod('getLocation'))
      .cast<String, double>();
    return LocationData.fromMap(resultMap);
  }

  /// Checks if the app has permission to access location.
  /// Returns a [PermissionStatus] object.
  ///
  /// If the result is [PermissionStatus.DENIED_FOREVER],
  /// no dialog will be shown on [requestPermission].
  Future<PermissionStatus> hasPermission() =>
    _methodChannel.invokeMethod('hasPermission').then((result) {
      switch (result) {
        case 0:
          return PermissionStatus.DENIED;
          break;
        case 1:
          return PermissionStatus.GRANTED;
          break;
        case 2:
          return PermissionStatus.DENIED_FOREVER;
        default:
          throw PlatformException(code: "UNKNOWN_NATIVE_MESSAGE");
      }
    });

  /// Request the permission to access the location
  /// Returns a [PermissionStatus] object.
  ///
  /// If the result is [PermissionStatus.DENIED_FOREVER],
  /// no dialog will be shown in the future.
  Future<PermissionStatus> requestPermission() =>
    _methodChannel.invokeMethod('requestPermission').then((result) {
      switch (result) {
        case 0:
          return PermissionStatus.DENIED;
          break;
        case 1:
          return PermissionStatus.GRANTED;
          break;
        case 2:
          return PermissionStatus.DENIED_FOREVER;
        default:
          throw PlatformException(code: "UNKNOWN_NATIVE_MESSAGE");
      }
    });

  /// Checks if the location service is enabled.
  Future<bool> serviceEnabled() =>
    _methodChannel
      .invokeMethod('serviceEnabled')
      .then((result) => result == 1);

  /// Request the activation of the location service.
  Future<bool> requestService() =>
    _methodChannel
      .invokeMethod('requestService')
      .then((result) => result == 1);

  /// Returns a stream of [LocationData] objects.
  /// The frequency and accuracy of this stream can be changed with [changeSettings]
  ///
  /// Throws an error if the app has no permission to access location.
  Stream<LocationData> onLocationChanged() {
    if (_onLocationChanged == null) {
      _onLocationChanged = _eventChannel
        .receiveBroadcastStream()
        .map<LocationData>((element) =>
        LocationData.fromMap(element.cast<String, double>()));
    }
    return _onLocationChanged;
  }
}
