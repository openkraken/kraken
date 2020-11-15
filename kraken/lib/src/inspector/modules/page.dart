import 'dart:convert';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:flutter/scheduler.dart';
import 'package:kraken/inspector.dart';
import 'package:kraken/dom.dart';
import '../module.dart';

class InspectPageModule extends InspectModule {
  final Inspector inspector;
  ElementManager get elementManager => inspector.elementManager;
  InspectPageModule(this.inspector);

  @override
  String get name => 'Page';

  @override
  void receiveFromFrontend(int id, String method, Map<String, dynamic> params) {
    switch (method) {
      case 'startScreencast':
        sendToFrontend(id, null);
        startScreenCast();
        break;
      case 'stopScreencast':
        sendToFrontend(id, null);
        stopScreenCast();
        break;
      case 'screencastFrameAck':
        sendToFrontend(id, null);
        handleScreencastFrameAck(params);
        break;
      case 'reload':
        sendToFrontend(id, null);
        handleReloadPage();
    }
  }

  void handleReloadPage() async {
    try {
      Inspector.prevInspector = elementManager.controller.view.inspector;
      await elementManager.controller.reload();
    } catch (e, stack) {
      print('Dart Error: $e\n$stack');
    }
  }

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

      sendEventToFrontend(event);
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
