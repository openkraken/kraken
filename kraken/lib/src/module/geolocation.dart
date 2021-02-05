import 'dart:async';
import 'dart:convert';

import 'package:kraken/src/module/module_manager.dart';
import 'package:kraken_geolocation/kraken_geolocation.dart';

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
typedef WatchPositionCallback = void Function(String result);

class GeolocationModule extends BaseModule {
  GeolocationModule(ModuleManager moduleManager) : super(moduleManager);

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

  static int watchPosition(Map<String, dynamic> options, WatchPositionCallback callback) {
    _changeOptions(options, true);
    _getLocation().then((location) {
      if (location == null) {
        String result = jsonEncode({'code': ERROR_CODE_PERMISSION_DENIED, 'message': 'permission denied'});
        callback(result);
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
        callback(result);
      }
      Stream<LocationData> stream = location.onLocationChanged();
      if (_streamSubscription == null) {
        stream.listen((locationData) {
          if (_watchCachedLocation == null ||
              (_watchCachedLocation != null && !_compareLocation(_watchCachedLocation, locationData))) {
            _watchCachedLocation = locationData;
            String result = _getLocationResult(_watchCachedLocation);
            callback(result);
          }
        }, onError: (e) {
          String result = jsonEncode({'code': ERROR_CODE_POSITION_UNAVAILABLE, 'message': e?.toString()});
          callback(result);
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

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  String invoke(String method, dynamic params, callback) {
    if (method == 'getCurrentPosition') {
      List positionArgs = params[2];
      Map<String, dynamic> options;
      if (positionArgs.length > 0) {
        options = positionArgs[0];
      }
      GeolocationModule.getCurrentPosition(options, (json) {
        callback(data: json);
      });
    } else if (method == 'watchPosition') {
      List positionArgs = params[2];
      Map<String, dynamic> options;
      if (positionArgs.length > 0) {
        options = positionArgs[0];
      }
      return GeolocationModule.watchPosition(options, (String result) {
        moduleManager.emitModuleEvent('geolocation', data: '["watchPosition", $result]');
      }).toString();
    } else if (method == 'clearWatch') {
      List positionArgs = params[2];
      int id = positionArgs[0];
      GeolocationModule.clearWatch(id);
    }
    return '';
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
