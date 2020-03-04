import 'dart:async';
import 'dart:convert';

import 'package:kraken/bridge.dart';
import 'package:location/location.dart';

//getCurrentPosition relative
bool enableHighAccuracy = false;
int timeout = -1;
int maximumAge = 0;
LocationData cachedLocation;

//watchPosition relative
bool watchEnableHighAccuracy = false;
int watchMaximumAge = 0;
int _watchId = 1;
const int ERROR_CODE_PERMISSION_DENIED = 1;
const int ERROR_CODE_POSITION_UNAVAILABLE = 2;
const int ERROR_CODE_TIMEOUT = 3;
StreamSubscription<LocationData> streamSubscription;
LocationData watchCachedLocation;

typedef Callback = void Function(String json);

void getCurrentPosition(Map<String, dynamic> options, Callback callback) async {
  Location location = await getLocation();
  if (location == null) {
    String result = jsonEncode(
        {'code': ERROR_CODE_PERMISSION_DENIED, "message": 'permission denied'});
    callback(result);
    return;
  }
  _changeOptions(options, false);
  location.changeSettings(
      accuracy:
          enableHighAccuracy ? LocationAccuracy.HIGH : LocationAccuracy.LOW);
  try {
    LocationData locationData;
    if (maximumAge > 0 &&
        cachedLocation != null &&
        (DateTime.now().microsecondsSinceEpoch - cachedLocation.time) <
            maximumAge) {
      callback(getLocationResult(cachedLocation));
      return;
    }
    if (timeout > 0) {
      locationData = await location
          .getLocation()
          .timeout(Duration(milliseconds: timeout), onTimeout: () {
        return null;
      });
    } else {
      locationData = await location.getLocation();
    }
    if (locationData == null) {
      String result =
          jsonEncode({'code': ERROR_CODE_TIMEOUT, "message": 'timeout'});
      callback(result);
    } else {
      cachedLocation = locationData;
      callback(getLocationResult(locationData));
    }
  } catch (e) {
    String result = jsonEncode(
        {'code': ERROR_CODE_POSITION_UNAVAILABLE, "message": e.toString()});
    callback(result);
  }
}

int watchPosition(Map<String, dynamic> options) {
  _changeOptions(options, true);
  getLocation().then((location) {
    if (location == null) {
      String result = jsonEncode({
        'code': ERROR_CODE_PERMISSION_DENIED,
        "message": 'permission denied'
      });
      emitModuleEvent('["watchPosition", $result]');
      if (streamSubscription != null) {
        streamSubscription.cancel();
        streamSubscription = null;
      }
      return;
    }
    location.changeSettings(
        accuracy: watchEnableHighAccuracy
            ? LocationAccuracy.HIGH
            : LocationAccuracy.LOW);
    if (watchMaximumAge > 0 &&
        watchCachedLocation != null &&
        (DateTime.now().microsecondsSinceEpoch - watchCachedLocation.time) <
            watchMaximumAge) {
      String result = getLocationResult(watchCachedLocation);
      emitModuleEvent('["watchPosition", $result]');
    }
    Stream<LocationData> stream = location.onLocationChanged();
    if (streamSubscription == null) {
      stream.listen((locationData) {
        if (watchCachedLocation == null ||
            (watchCachedLocation != null &&
                !_compareLocation(watchCachedLocation, locationData))) {
          watchCachedLocation = locationData;
          String result = getLocationResult(watchCachedLocation);
          emitModuleEvent('["watchPosition", $result]');
        }
      }, onError: (e) {
        String result = jsonEncode({
          'code': ERROR_CODE_POSITION_UNAVAILABLE,
          "message": e?.toString()
        });
        emitModuleEvent('["watchPosition", $result]');
      }, cancelOnError: false);
    }
  });
  return _watchId++;
}

void clearWatch(int id) async {
  if (streamSubscription != null) {
    streamSubscription.cancel();
    streamSubscription = null;
  }
}

void _changeOptions(Map<String, dynamic> options, bool isWatched) {
  if (options != null) {
    if (options.containsKey('enableHighAccuracy') &&
        options['enableHighAccuracy'] == true) {
      if (isWatched) {
        watchEnableHighAccuracy = true;
      } else {
        enableHighAccuracy = true;
      }
    }
    if (options.containsKey('timeout')) {
      if (isWatched) {
//        watchTimeout = options['timeout'];
      } else {
        timeout = options['timeout'];
      }
    }
    if (options.containsKey('maximumAge')) {
      if (isWatched) {
        watchMaximumAge = options['maximumAge'];
      } else {
        maximumAge = options['maximumAge'];
      }
    }
  }
}

bool _compareLocation(LocationData cachedData, LocationData data) {
  return cachedData.altitudeAccuracy == data.altitudeAccuracy &&
      cachedData.altitude == data.altitude &&
      cachedData.latitude == data.latitude &&
      cachedData.longitude == data.longitude &&
      cachedData.speed == data.speed &&
      cachedData.heading == data.heading &&
      cachedData.accuracy == data.accuracy;
}

String getLocationResult(LocationData locationData) {
  return jsonEncode({
    'coords': {
      'latitude': locationData?.latitude ?? 0.0,
      'longitude': locationData?.longitude ?? 0.0,
      'accuracy': locationData?.accuracy ?? 0.0,
      'altitude': locationData?.altitude ?? 0.0,
      'altitudeAccuracy': locationData?.altitudeAccuracy ?? 0.0,
      'speed': locationData?.speed ?? 0.0,
      'heading': locationData?.heading ?? 0.0
    },
    'timestamp': locationData?.time?.toInt() ?? 0
  });
}

Future<Location> getLocation() async {
  Location location = Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return null;
    }
  }

  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.DENIED) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.GRANTED) {
      return null;
    }
  }

  return location;
}
