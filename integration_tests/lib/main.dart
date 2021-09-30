import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/foundation.dart';
import 'package:kraken/module.dart';
import 'package:kraken/widget.dart';
import 'package:ansicolor/ansicolor.dart';
import 'package:path/path.dart' as path;
import 'bridge/from_native.dart';
import 'bridge/to_native.dart';
import 'bridge/test_input.dart';
import 'custom/custom_object_element.dart';
import 'custom/custom_element_widget.dart';
import 'package:kraken/gesture.dart';
import 'package:kraken_websocket/kraken_websocket.dart';
import 'package:kraken_animation_player/kraken_animation_player.dart';
import 'package:kraken_video_player/kraken_video_player.dart';
import 'package:kraken_webview/kraken_webview.dart';
import 'local_http_server.dart';

String? pass = (AnsiPen()..green())('[TEST PASS]');
String? err = (AnsiPen()..red())('[TEST FAILED]');

final String __dirname = path.dirname(Platform.script.path);
final String testDirectory = Platform.environment['KRAKEN_TEST_DIR'] ?? __dirname;
final Directory specsDirectory = Directory(path.join(testDirectory, '.specs'));

const int KRAKEN_NUM = 1;
Map<int, Kraken> krakenMap = Map();

// Test for UriParser.
class IntegrationTestUriParser extends UriParser {
  @override
  Uri resolve(Uri base, Uri relative) {
    if (base.toString().isEmpty
        && relative.path.startsWith('assets/')) {
      return Uri.file(relative.path);
    } else {
      return super.resolve(base, relative);
    }
  }
}

// By CLI: `KRAKEN_ENABLE_TEST=true flutter run`
void main() async {
  KrakenWebsocket.initialize();
  KrakenAnimationPlayer.initialize();
  KrakenVideoPlayer.initialize();
  KrakenWebView.initialize();
  defineKrakenCustomElements();

  // FIXME: This is a workaround for testcase
  ParagraphElement.defaultStyle = {
    DISPLAY: BLOCK,
  };

  // Local HTTP server.
  var httpServer = LocalHttpServer.getInstance();
  print('Local HTTP server started at: ${httpServer.getUri()}');

  String codeInjection = '''
    // This segment inject variables for test environment.
    LOCAL_HTTP_SERVER = '${httpServer.getUri().toString()}';
  ''';

  // Set render font family AlibabaPuHuiTi to resolve rendering difference.
  CSSText.DEFAULT_FONT_FAMILY_FALLBACK = ['AlibabaPuHuiTi'];
  setObjectElementFactory(customObjectElementFactory);

  List<FileSystemEntity> specs = specsDirectory.listSync(recursive: true);
  List<Map<String, String>> mainTestPayload = [];
  for (FileSystemEntity file in specs) {
    if (file.path.endsWith('js')) {
      String filename = path.basename(file.path);
      String code = File(file.path).readAsStringSync();
      mainTestPayload.add({
        'filename': filename,
        'filepath': file.path,
        'code': code,
      });
    }
  }

  List<List<Map<String, String>>> allSpecsPayload = [
    mainTestPayload,
    mainTestPayload.reversed.toList()
  ];
  List<Widget> widgets = [];

  for (int i = 0; i < KRAKEN_NUM; i ++) {
    KrakenJavaScriptChannel javaScriptChannel = KrakenJavaScriptChannel();
    javaScriptChannel.onMethodCall = (String method, dynamic arguments) async {
      javaScriptChannel.invokeMethod(method, arguments);
      return 'method: ' + method;
    };

    var kraken = krakenMap[i] = Kraken(
      viewportWidth: 360,
      viewportHeight: 640,
      bundleContent: 'console.log("Starting integration tests...")',
      disableViewportWidthAssertion: true,
      disableViewportHeightAssertion: true,
      javaScriptChannel: javaScriptChannel,
      eventClient: EventClient(
        onDrag: (GestureEvent gestureEvent) {
          if (gestureEvent.state == EVENT_STATE_START) {
            var event = CustomEvent('nativegesture', CustomEventInit(detail: 'nativegesture'));
            krakenMap[i]!.controller!.view.document!.documentElement.dispatchEvent(event);
          }
        },
      ),
      uriParser: IntegrationTestUriParser(),
    );
    widgets.add(kraken);
  }

  runApp(MaterialApp(
    title: 'Kraken Integration Tests',
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      appBar: AppBar(
        title: Text('Kraken Integration Tests')
      ),
      body: Wrap(
        children: widgets,
      ),
    ),
  ));

  testTextInput = TestTextInput();
  testTextInput.register();

  WidgetsBinding.instance!.addPostFrameCallback((_) async {
    registerDartTestMethodsToCpp();

    List<Future<String>> testResults = [];

    for (int i = 0; i < widgets.length; i ++) {
      int contextId = i;
      initTestFramework(contextId);
      addJSErrorListener(contextId, (String err) {
        print(err);
      });

      List<Map<String, String>> testPayload = allSpecsPayload[i];

      // Preload load test cases
      for (Map spec in testPayload) {
        String filename = spec['filename'];
        String code = spec['code'];
        evaluateTestScripts(contextId, codeInjection + code, url: filename);
      }

      testResults.add(executeTest(contextId));
    }

    List<String> results = await Future.wait(testResults);

    for (int i = 0; i < results.length; i ++) {
      String status = results[i];
      if (status == 'failed') {
        exit(1);
      }
    }

    exit(0);
  });
}

