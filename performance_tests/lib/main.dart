import 'package:flutter/material.dart';
import 'package:kraken/kraken.dart';
import 'dart:ui';
import 'dart:io';
import 'dart:async';

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

  @override
  void initState() {
    Timer.run(_runKrakenPage);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    KrakenJavaScriptChannel javaScriptChannel = KrakenJavaScriptChannel();
    javaScriptChannel.onMethodCall = (String method, arguments) async {
      if (method == 'firstPaint') {
        _krakenOnloadTimes.add((arguments as List)[0] as int);
        Timer.run(_runKrakenPage);
      }
    };

    return Scaffold(
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: _kraken = Kraken(
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
          )
        ));
  }
}
