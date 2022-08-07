/*
 * Copyright (C) 2022-present The Kraken authors. All rights reserved.
 */

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webf/webf.dart';
import 'package:webview_flutter/webview_flutter.dart';

const benchMarkServer = String.fromEnvironment("SERVER");

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kraken Browser',
      // theme: ThemeData.dark(),
      home: MyBrowser(),
    );
  }
}

class MyBrowser extends StatefulWidget {
  MyBrowser({Key? key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

typedef PerformanceDataCallback = void Function(String viewType, int time);

class _WebViewPage extends StatelessWidget {
  final PerformanceDataCallback _performanceDataCallback;
  final int _startTime;

  _WebViewPage(PerformanceDataCallback performanceDataCallback)
      : _performanceDataCallback = performanceDataCallback,
        _startTime = DateTime.now().millisecondsSinceEpoch;

  JavascriptChannel _javascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Message',
        onMessageReceived: (JavascriptMessage message) {
          _performanceDataCallback('Web', int.parse(message.message) - _startTime);
        });
  }

  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: 'http://$benchMarkServer/web/home.html',
      javascriptMode: JavascriptMode.unrestricted,
      javascriptChannels: <JavascriptChannel>{
        _javascriptChannel(context),
      },
    );
  }
}

class _KrakenPage extends StatelessWidget {
  final PerformanceDataCallback _performanceDataCallback;
  final int _startTime;

  _KrakenPage(PerformanceDataCallback performanceDataCallback)
      : _performanceDataCallback = performanceDataCallback,
        _startTime = DateTime.now().millisecondsSinceEpoch;

  WebFJavaScriptChannel get javaScriptChannel => WebFJavaScriptChannel()
    ..onMethodCall = (String method, arguments) async {
      if (method == 'performance') {
        _performanceDataCallback('WebF', int.parse((arguments as List)[0]) - _startTime);
      }
    };

  @override
  Widget build(BuildContext context) {
    return WebF(
      bundle: WebFBundle.fromUrl('http://$benchMarkServer/kraken/home.kbc1'),
      javaScriptChannel: javaScriptChannel,
    );
  }
}

class _MyHomePageState extends State<MyBrowser> {
  Widget? _currentView;

  List<int> _krakenLoadTimes = [];
  List<int> _webLoadTimes = [];
  final int _collectCount = 60;

  OutlineInputBorder outlineBorder = OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent, width: 0.0),
    borderRadius: const BorderRadius.all(
      Radius.circular(20.0),
    ),
  );

  void _changeViewAndReloadPage() async {
    setState(() {
      _currentView = _currentView is _KrakenPage ? _WebViewPage(_getPerformanceData) : _KrakenPage(_getPerformanceData);
    });
  }

  void _getPerformanceData(String viewType, int time) {
    if (viewType == 'Kraken') {
      _krakenLoadTimes.add(time);
    } else {
      _webLoadTimes.add(time);
    }

    if (_krakenLoadTimes.length >= _collectCount && _webLoadTimes.length >= _collectCount) {
      print('Performance: $_krakenLoadTimes');
      print('Performance: $_webLoadTimes');

      Timer(Duration(seconds: 1), () {
        exit(0);
      });
    } else {
      Timer(Duration(seconds: 1), _changeViewAndReloadPage);
    }
  }

  @override
  void initState() {
    super.initState();

    Timer.run(_changeViewAndReloadPage);
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController textEditingController = TextEditingController();

    AppBar appBar = AppBar(
      backgroundColor: Colors.black87,
      titleSpacing: 10.0,
      title: Container(
        height: 40.0,
        child: TextField(
          controller: textEditingController,
          onSubmitted: (value) {
            textEditingController.text = value;
          },
          decoration: InputDecoration(
            hintText: 'Enter URL',
            hintStyle: TextStyle(color: Colors.black54, fontSize: 16.0),
            contentPadding: const EdgeInsets.all(10.0),
            filled: true,
            fillColor: Colors.grey,
            border: outlineBorder,
            focusedBorder: outlineBorder,
            enabledBorder: outlineBorder,
          ),
          style: TextStyle(color: Colors.black, fontSize: 16.0),
        ),
      ),
      // Here we take the value from the MyHomePage object that was created by
      // the App.build method, and use it to set our appbar title.
    );

    return Scaffold(
        appBar: appBar,
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: _currentView ?? Text('Performance test'),
        ));
  }
}
