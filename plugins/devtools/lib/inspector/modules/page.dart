import 'dart:convert';
import 'dart:typed_data';

import 'package:kraken_devtools/kraken_devtools.dart';
import 'package:meta/meta.dart';
import 'package:flutter/scheduler.dart';
import 'package:kraken/dom.dart';
import '../module.dart';
import '../ui_inspector.dart';

String enumKey(String key) {
  return key.split('.').last;
}

class PageScreenCastFrameEvent extends InspectorEvent {
  @override
  String get method => 'Page.screencastFrame';

  @override
  JSONEncodable get params => _screenCastFrame;

  final ScreenCastFrame _screenCastFrame;

  PageScreenCastFrameEvent(this._screenCastFrame);
}

// Information about the Frame on the page.
class Frame extends JSONEncodable {
  // Frame unique identifier.
  final String id;

  // Parent frame identifier.
  String? parentId;

  // Identifier of the loader associated with this frame.
  final String loaderId;

  // Frame's name as specified in the tag.
  String? name;

  // Frame document's URL without fragment.
  final String url;

  // Frame document's URL fragment including the '#'.
  String? urlFragment;

  // Frame document's registered domain, taking the public suffixes list into account. Extracted from the Frame's url. Example URLs: http://www.google.com/file.html -> "google.com" http://a.b.co.uk/file.html -> "b.co.uk"
  final String domainAndRegistry;

  // Frame document's security origin.
  final String securityOrigin;

  // Frame document's mimeType as determined by the browser.
  final String mimeType;

  // If the frame failed to load, this contains the URL that could not be loaded. Note that unlike url above, this URL may contain a fragment.
  String? unreachableUrl;

  // Indicates whether this frame was tagged as an ad.
  String? AdFrameType;

  // Indicates whether the main document is a secure context and explains why that is the case.
  final String secureContextType;

  // Indicates whether this is a cross origin isolated context.
  final String crossOriginIsolatedContextType;

  // Indicated which gated APIs / features are available.
  final List<String> gatedAPIFeatures;

  Frame(
      this.id,
      this.loaderId,
      this.url,
      this.domainAndRegistry,
      this.securityOrigin,
      this.mimeType,
      this.secureContextType,
      this.crossOriginIsolatedContextType,
      this.gatedAPIFeatures,
      {this.parentId,
      this.name,
      this.urlFragment,
      this.unreachableUrl,
      this.AdFrameType});

  @override
  Map toJson() {
    Map<String, dynamic> map = {
      'id': id,
      'loaderId': loaderId,
      'url': url,
      'domainAndRegistry': domainAndRegistry,
      'securityOrigin': securityOrigin,
      'mimeType': mimeType,
      'secureContextType': secureContextType,
      'crossOriginIsolatedContextType': crossOriginIsolatedContextType,
      'gatedAPIFeatures': gatedAPIFeatures
    };

    if (parentId != null) map['parentId'] = parentId;
    if (name != null) map['name'] = name;
    if (urlFragment != null) map['urlFragment'] = urlFragment;
    if (unreachableUrl != null) map['unreachableUrl'] = unreachableUrl;
    if (AdFrameType != null) map['AdFrameType'] = AdFrameType;
    return map;
  }
}

class FrameResource extends JSONEncodable {
  // Resource URL.
  final String url;

  // Type of this resource.
  final String type;

  // Resource mimeType as determined by the browser.
  final String mimeType;

  // last-modified timestamp as reported by server.
  int? lastModified;

  // Resource content size.
  int? contentSize;

  // True if the resource failed to load.
  bool? failed;

  // True if the resource was canceled during loading.
  bool? canceled;

  FrameResource(this.url, this.type, this.mimeType,
      {this.lastModified, this.contentSize, this.failed, this.canceled});

  @override
  Map toJson() {
    Map<String, dynamic> map = {'url': url, 'type': type, 'mimeType': mimeType};
    if (lastModified != null) map['lastModified'] = lastModified;
    if (contentSize != null) map['contentSize'] = contentSize;
    if (failed != null) map['failed'] = failed;
    if (canceled != null) map['canceled'] = canceled;
    return map;
  }
}

// Information about the Frame hierarchy along with their cached resources.
class FrameResourceTree extends JSONEncodable {
  // Frame information for this tree item.
  final Frame frame;

  // Child frames.
  List<FrameResourceTree>? childFrames;

  // Information about frame resources.
  final List<FrameResource> resources;

  FrameResourceTree(this.frame, this.resources, {this.childFrames});

  @override
  Map toJson() {
    Map<String, dynamic> map = {'frame': frame, 'resources': resources};
    if (childFrames != null) map['childFrames'] = childFrames;
    return map;
  }
}

enum ResourceType {
  Document,
  Stylesheet,
  Image,
  Media,
  Font,
  Script,
  TextTrack,
  XHR,
  Fetch,
  EventSource,
  WebSocket,
  Manifest,
  SignedExchange,
  Ping,
  CSPViolationReport,
  Preflight,
  Other
}

class InspectPageModule extends UIInspectorModule {

  Document get document => devTool!.controller!.view.document;

  InspectPageModule(ChromeDevToolsService? devTool): super(devTool);

  @override
  String get name => 'Page';

  @override
  void receiveFromFrontend(int? id, String method, Map<String, dynamic>? params) {
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
        handleScreencastFrameAck(params!);
        break;
      case 'getResourceContent':
        sendToFrontend(id, JSONEncodableMap({
          'content': devTool!.controller?.bundle?.content,
          'base64Encoded': false
        }));
        break;
      case 'reload':
        sendToFrontend(id, null);
        handleReloadPage();
        break;
      default:
        sendToFrontend(id, null);
    }
  }

  void handleReloadPage() async {
    try {
      await document.controller.reload();
    } catch (e, stack) {
      print('Dart Error: $e\n$stack');
    }
  }

  int? _lastSentSessionID;
  bool _isFramingScreenCast = false;

  void _frameScreenCast(Duration timeStamp) {
    Element root = document.documentElement!;
    root.toBlob().then((Uint8List screenShot) {
      String encodedImage = base64Encode(screenShot);
      _lastSentSessionID = timeStamp.inMilliseconds;
      InspectorEvent event = PageScreenCastFrameEvent(ScreenCastFrame(
          encodedImage,
          ScreencastFrameMetadata(
            0,
            1,
            document.viewport.viewportSize.width,
            document.viewport.viewportSize.height,
            root.getOffsetX(),
            root.getOffsetY(),
            timestamp: timeStamp.inMilliseconds,
          ),
          _lastSentSessionID!));

      sendEventToFrontend(event);
    });
  }

  void startScreenCast() {
    _isFramingScreenCast = true;
    SchedulerBinding.instance!.addPostFrameCallback(_frameScreenCast);
    SchedulerBinding.instance!.scheduleFrame();
  }

  void stopScreenCast() {
    _isFramingScreenCast = false;
  }

  /// Avoiding frame blocking, confirm frontend has ack last frame,
  /// and then send next frame.
  void handleScreencastFrameAck(Map<String, dynamic> params) {
    int? ackSessionID = params['sessionId'];
    if (ackSessionID == _lastSentSessionID && _isFramingScreenCast) {
      SchedulerBinding.instance!.addPostFrameCallback(_frameScreenCast);
    }
  }
}

@immutable
class ScreenCastFrame implements JSONEncodable {
  final String data;
  final ScreencastFrameMetadata metadata;
  final int sessionId;

  ScreenCastFrame(this.data, this.metadata, this.sessionId)
      : assert(data != null),
        assert(metadata != null),
        assert(sessionId != null);

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
  final num? timestamp;

  ScreencastFrameMetadata(
      this.offsetTop,
      this.pageScaleFactor,
      this.deviceWidth,
      this.deviceHeight,
      this.scrollOffsetX,
      this.scrollOffsetY,
      {this.timestamp});

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
