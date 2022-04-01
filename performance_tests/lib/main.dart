import 'package:flutter/material.dart';
import 'package:kraken/kraken.dart';
import 'dart:ui';
import 'dart:io';
import 'dart:async';

import 'package:webview_flutter/webview_flutter.dart';

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

class _MyHomePageState extends State<MyBrowser> {

  Kraken? _kraken;
  WebView? _webView;

  List<int> _krakenOnloadTimes = [];
  List _webonloadTimes = [];
  int _collectCount = 30;

  OutlineInputBorder outlineBorder = OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent, width: 0.0),
    borderRadius: const BorderRadius.all(
      Radius.circular(20.0),
    ),
  );

  void _runKrakenPage() async {
    if (_krakenOnloadTimes.length < _collectCount) {
      await _kraken?.reload();
    } else {
      print('_krakenPaintTimes=$_krakenOnloadTimes');
      // End of collect Kraken performance.
    }
  }

  JavascriptChannel _javascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Message',
        onMessageReceived: (JavascriptMessage message) {
          print('firstPaint=${message.message}');
        }
    );
  }

  @override
  void initState() {
    Timer.run(_runKrakenPage);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData queryData = MediaQuery.of(context);
    final Size viewportSize = queryData.size;
    final TextEditingController textEditingController = TextEditingController();

    KrakenJavaScriptChannel javaScriptChannel = KrakenJavaScriptChannel();
    javaScriptChannel.onMethodCall = (String method, arguments) async {
      if (method == 'firstPaint') {
        _krakenOnloadTimes.add((arguments as List)[0] as int);
        Timer.run(_runKrakenPage);
      }
    };

    AppBar appBar = AppBar(
      backgroundColor: Colors.black87,
      titleSpacing: 10.0,
      title: Container(
        height: 40.0,
        child: TextField(
          controller: textEditingController,
          onSubmitted: (value) {
            textEditingController.text = value;
            _kraken?.load(KrakenBundle.fromUrl(value));
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
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: _kraken = Kraken(
                    viewportWidth: (viewportSize.width - queryData.padding.horizontal) / 2,
                    viewportHeight: viewportSize.height - appBar.preferredSize.height - queryData.padding.vertical,
                    bundle: KrakenBundle.fromUrl('assets:///benchmark/build/kraken/home.kbc1'),
                    javaScriptChannel: javaScriptChannel,
                    onLoad: (KrakenController controller) {
                      // Timer(Duration(seconds: 4), () {
                      //   exit(0);
                      // });
                      controller.view.evaluateJavaScripts("""setTimeout(() => {
                            console.log(performance.__kraken_navigation_summary__());
                          }, 2000);""");
                    },
                  ),
                ),
                Expanded(
                  child: _webView = WebView(
                    initialUrl: 'http://192.168.1.196:3333/home.html',
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (WebViewController controller)  {
                      controller.clearCache();
                    },
                    javascriptChannels: <JavascriptChannel>{
                      _javascriptChannel(context),
                    },
                  ),
                  flex: 1,
                ),
              ],
            )
        ));
  }
}
