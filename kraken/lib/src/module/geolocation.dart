import 'dart:async';
import 'dart:convert';

import 'package:kraken/bridge.dart';
import 'package:location/location.dart';

// getCurrentPosition relative
bool enableHighAccuracy = false;
int timeout = -1;
int maximumAge = 0;
LocationData _cachedLocation;

// watchPosition relative
bool watchEnableHighAccuracy = false;
int watchMaximumAge = 0;
int _watchId = 1;
const int ERROR_CODE_PERMISSION_DENIED = 1;
const int ERROR_CODE_POSITION_UNAVAILABLE = 2;
const int ERROR_CODE_TIMEOUT = 3;
StreamSubscription<LocationData> _streamSubscription;
LocationData _watchCachedLocation;

typedef Callback = void Function(String json);

class Geolocation {
  static void getCurrentPosition(Map<String, dynamic> options, Callback callback) async {
    Location location = await _getLocation();
    if (location == null) {
      String result = jsonEncode({'code': ERROR_CODE_PERMISSION_DENIED, "message": 'permission denied'});
      callback(result);
      return;
    }
    // TODO: options is only for current call, not set to global
    _changeOptions(options, false);
    location.changeSettings(accuracy: enableHighAccuracy ? LocationAccuracy.HIGH : LocationAccuracy.LOW);
    try {
      LocationData locationData;
      if (maximumAge > 0 &&
          _cachedLocation != null &&
          (DateTime.now().microsecondsSinceEpoch - _cachedLocation.time) < maximumAge) {
        callback(_getLocationResult(_cachedLocation));
        return;
      }
      if (timeout > 0) {
        locationData = await location.getLocation().timeout(Duration(milliseconds: timeout), onTimeout: () {
          return null;
        });
      } else {
        locationData = await location.getLocation();
      }
      if (locationData == null) {
        String result = jsonEncode({'code': ERROR_CODE_TIMEOUT, "message": 'timeout'});
        callback(result);
      } else {
        _cachedLocation = locationData;
        callback(_getLocationResult(locationData));
      }
    } catch (e) {
      String result = jsonEncode({'code': ERROR_CODE_POSITION_UNAVAILABLE, "message": e.toString()});
      callback(result);
    }
  }

  static int watchPosition(Map<String, dynamic> options) {
    _changeOptions(options, true);
    _getLocation().then((location) {
      if (location == null) {
        String result = jsonEncode({'code': ERROR_CODE_PERMISSION_DENIED, 'message': 'permission denied'});
        emitModuleEvent('["watchPosition", $result]');
        if (_streamSubscription != null) {
          _streamSubscription.cancel();
          _streamSubscription = null;
        }
        return;
      }
      location.changeSettings(accuracy: watchEnableHighAccuracy ? LocationAccuracy.HIGH : LocationAccuracy.LOW);
      if (watchMaximumAge > 0 &&
          _watchCachedLocation != null &&
          (DateTime.now().microsecondsSinceEpoch - _watchCachedLocation.time) < watchMaximumAge) {
        String result = _getLocationResult(_watchCachedLocation);
        emitModuleEvent('["watchPosition", $result]');
      }
      Stream<LocationData> stream = location.onLocationChanged();
      if (_streamSubscription == null) {
        stream.listen((locationData) {
          if (_watchCachedLocation == null ||
              (_watchCachedLocation != null && !_compareLocation(_watchCachedLocation, locationData))) {
            _watchCachedLocation = locationData;
            String result = _getLocationResult(_watchCachedLocation);
            emitModuleEvent('["watchPosition", $result]');
          }
        }, onError: (e) {
          String result = jsonEncode({'code': ERROR_CODE_POSITION_UNAVAILABLE, 'message': e?.toString()});
          emitModuleEvent('["watchPosition", $result]');
        }, cancelOnError: false);
      }
    });
    return _watchId++;
  }

  static void clearWatch(int id) async {
    if (_streamSubscription != null) {
      _streamSubscription.cancel();
      _streamSubscription = null;
    }
  }
}

void _changeOptions(Map<String, dynamic> options, bool isWatched) {
  if (options != null) {
    if (options.containsKey('enableHighAccuracy') && options['enableHighAccuracy'] == true) {
      if (isWatched) {
        watchEnableHighAccuracy = true;
      } else {
        enableHighAccuracy = true;
      }
    }
    if (options.containsKey('timeout')) {
      if (!isWatched) {
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

String _getLocationResult(LocationData locationData) {
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

Future<Location> _getLocation() async {
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
