import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/inspector.dart';

class InspectorPageAgent {
  Inspector inspector;
  ElementManager get elementManager => inspector.elementManager;
  InspectorPageAgent(this.inspector);

  int _lastSentSessionID;

  bool _isFramingScreenCast = false;
  void _frameScreenCast(Duration timeStamp) {
    Element root = elementManager.getRootElement();
    root.toBlob().then((Uint8List screenShot) {
      String encodedImage = base64Encode(screenShot);
      _lastSentSessionID = timeStamp.inMilliseconds;
      InspectorEvent event = InspectorEvent(
        'Page.screencastFrame',
        ScreenCastFrame(
            encodedImage,
            ScreencastFrameMetadata(
              0,
              1,
              elementManager.viewportWidth,
              elementManager.viewportHeight,
              root.getOffsetX(),
              root.getOffsetY(),
              timestamp: timeStamp.inMilliseconds,
            ),
            _lastSentSessionID
        )
      );

      inspector.ws.add(jsonEncode(event));
    });
  }

  void startScreenCast() {
    _isFramingScreenCast = true;
    SchedulerBinding.instance.addPostFrameCallback(_frameScreenCast);
    SchedulerBinding.instance.scheduleFrame();
  }

  void stopScreenCast() {
    _isFramingScreenCast = false;
  }

  /// Avoiding frame blocking, confirm frontend has ack last frame,
  /// and then send next frame.
  void handleScreencastFrameAck(Map<String, dynamic> params) {
    int ackSessionID = params['sessionId'];
    if (ackSessionID == _lastSentSessionID && _isFramingScreenCast) {
      SchedulerBinding.instance.addPostFrameCallback(_frameScreenCast);
    }
  }

  ResponseState onRequest(Map<String, dynamic> params, String method, InspectorData protocolData) {
    switch (method) {
      case 'Page.startScreencast':
        startScreenCast();
        break;
      case 'Page.stopScreencast':
        stopScreenCast();
        break;
      case 'Page.screencastFrameAck':
        handleScreencastFrameAck(params);
        break;
    }

    return ResponseState.Success;
  }
}

@immutable
class ScreenCastFrame implements JSONEncodable {
  final String data;
  final ScreencastFrameMetadata metadata;
  final int sessionId;
  ScreenCastFrame(this.data, this.metadata, this.sessionId)
   : assert(data != null), assert(metadata != null) , assert(sessionId != null);

  Map toJson() {
    return {
      'data': data,
      'metadata': metadata.toJson(),
      'sessionId': sessionId,
    };
  }
}

@immutable
class ScreencastFrameMetadata implements JSONEncodable {
  final num offsetTop;
  final num pageScaleFactor;
  final num deviceWidth;
  final num deviceHeight;
  final num scrollOffsetX;
  final num scrollOffsetY;
  final num timestamp;

  ScreencastFrameMetadata(
    this.offsetTop,
    this.pageScaleFactor,
    this.deviceWidth,
    this.deviceHeight,
    this.scrollOffsetX,
    this.scrollOffsetY,
    { this.timestamp }
  );

  Map toJson() {
    return {
      'offsetTop': offsetTop,
      'pageScaleFactor': pageScaleFactor,
      'deviceWidth': deviceWidth,
      'deviceHeight': deviceHeight,
      'scrollOffsetX': scrollOffsetX,
      'scrollOffsetY': scrollOffsetY,
      'timestamp': timestamp
    };
  }
}

@immutable
class InspectorEvent implements JSONEncodable {
  final String method;
  final JSONEncodable params;
  InspectorEvent(this.method, this.params) : assert(method != null);

  Map toJson() {
    return {
      'method': method,
      'params': params.toJson(),
    };
  }
}
