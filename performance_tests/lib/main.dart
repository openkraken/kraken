import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kraken/kraken.dart';
import 'dart:ui';
import 'dart:async';

import 'package:webview_flutter/webview_flutter.dart';

const benchMarkServerAddress = String.fromEnvironment("IP");

void main(List<String> args) {
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

class _WebviewPage extends StatelessWidget {
  late int _startTime;
  _WebviewPage(PerformanceDataCallback performanceDataCallback) : _performanceDataCallback = performanceDataCallback {
    _startTime = DateTime.now().millisecondsSinceEpoch;
  }

  late PerformanceDataCallback _performanceDataCallback;

  JavascriptChannel _javascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Message',
        onMessageReceived: (JavascriptMessage message) {
          _performanceDataCallback('Web', int.parse(message.message) - _startTime);
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: 'http://$benchMarkServerAddress:7878/web/home.html',
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController controller)  {
        // controller.clearCache();
      },
      javascriptChannels: <JavascriptChannel>{
        _javascriptChannel(context),
      },
    );
  }
}

class _KrakenPage extends StatelessWidget {
  late int _startTime;
  _KrakenPage(PerformanceDataCallback performanceDataCallback) : _performanceDataCallback = performanceDataCallback {
    _startTime = DateTime.now().millisecondsSinceEpoch;
  }

  late PerformanceDataCallback _performanceDataCallback;

  @override
  Widget build(BuildContext context) {
    KrakenJavaScriptChannel javaScriptChannel = KrakenJavaScriptChannel();
    javaScriptChannel.onMethodCall = (String method, arguments) async {
      if (method == 'performance') {
        _performanceDataCallback('Kraken', int.parse((arguments as List)[0]) - _startTime);
      }
    };

    return Kraken(
      bundle: KrakenBundle.fromUrl('http://$benchMarkServerAddress:7878/kraken/home.kbc1'),
      javaScriptChannel: javaScriptChannel,
      onLoad: (KrakenController controller) {
        // controller.view.evaluateJavaScripts("""setTimeout(() => {
        //   console.log(performance.__kraken_navigation_summary__());
        // }, 2000);""");
      },
    );
  }
}

class _MyHomePageState extends State<MyBrowser> {
  Widget? _currentView;

  List<int> _krakenOnloadTimes = [];
  List<int> _webOnloadTimes = [];
  final int _collectCount = 30;

  OutlineInputBorder outlineBorder = OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent, width: 0.0),
    borderRadius: const BorderRadius.all(
      Radius.circular(20.0),
    ),
  );

  void _changeViewAndReloadPage() async {
    if (_currentView is _KrakenPage) {
      setState(() {
        _currentView = _WebviewPage(_getPerformanceData);
      });
    } else {
      setState(() {
        _currentView = _KrakenPage(_getPerformanceData);
      });
    }
  }

  void _getPerformanceData(String viewType, int time) {
    print('_getPerformanceData viewType=$viewType, time=$time');
    if (viewType == 'Kraken') {
      _krakenOnloadTimes.add(time);
    } else {
      _webOnloadTimes.add(time);
    }

    if (_krakenOnloadTimes.length >= _collectCount && _webOnloadTimes.length >= _collectCount) {
      print('The list of Average time in Kraken from loading to the onLoad is $_krakenOnloadTimes (ms)');
      print('The list of Average time in webview from loading to the onLoad is $_webOnloadTimes (ms)');

      // Remove the top five and the bottom five from the final numbers to eliminate fluctuations, and calculate the average.
      _krakenOnloadTimes.sort();
      _krakenOnloadTimes.removeRange(0, 5);
      _krakenOnloadTimes.removeRange(_krakenOnloadTimes.length - 5, _krakenOnloadTimes.length);
      int sumKrakenLoadTimes = 0;
      _krakenOnloadTimes.forEach((t) => sumKrakenLoadTimes += t);
      int averageKrakenLoadTime = sumKrakenLoadTimes ~/ _krakenOnloadTimes.length;

      _webOnloadTimes.sort();
      _webOnloadTimes.removeRange(0, 5);
      _webOnloadTimes.removeRange(_webOnloadTimes.length - 5, _webOnloadTimes.length);
      int sumWebLoadTimes = 0;
      _webOnloadTimes.forEach((t) => sumWebLoadTimes += t);
      int averageWebLoadTime = sumWebLoadTimes ~/ _webOnloadTimes.length;

      print('The Average time in Kraken from loading to the onLoad is $averageKrakenLoadTime ms');
      print('The Average time in webview from loading to the onLoad is $averageWebLoadTime ms');

      Timer(Duration(seconds: 2), () {
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
    final MediaQueryData queryData = MediaQuery.of(context);
    final Size viewportSize = queryData.size;
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
            hintText: 'Enter a app url',
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
