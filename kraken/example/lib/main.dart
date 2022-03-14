import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/devtools.dart';
import 'package:kraken_example/mock_prescript.dart';
import 'package:kraken_websocket/kraken_websocket.dart';


@pragma('vm:entry-point')
void top() => runApp( MyApp());

@pragma('vm:entry-point')
void bottom() => runApp( MyApp());

void main() {
  KrakenWebsocket.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kraken Browser',
      // theme: ThemeData.dark(),
      home: MyHomePage(title: 'First Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String? title;
  const MyHomePage({Key? key, this.title}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'MyHomePage'),
      ),
      body: Center(
        //这是一个IOS风格材质的按钮，需要导入cupertino文件才能引用
          child: CupertinoButton(
              color: Colors.blue,
              child: Text('Push Kraken Page'),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyBrowser(
                          title: 'Kraken Page',
                        )));
              })),
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

  OutlineInputBorder outlineBorder = OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent, width: 0.0),
    borderRadius: const BorderRadius.all(
      Radius.circular(20.0),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final MediaQueryData queryData = MediaQuery.of(context);
    final TextEditingController textEditingController = TextEditingController();

    Kraken? _kraken;
    AppBar appBar = AppBar(
        backgroundColor: Colors.black87,
        titleSpacing: 10.0,
        title: Container(
          height: 40.0,
          child: TextField(
            controller: textEditingController,
            onSubmitted: (value) {
              textEditingController.text = value;
              _kraken?.loadBundle(KrakenBundle.fromUrl(value));
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

    final Size viewportSize = queryData.size;
    return Scaffold(
        appBar: appBar,
        body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: _kraken = Kraken(
          devToolsService: ChromeDevToolsService(),
          onLoad: onJsBundleLoad,
          viewportWidth: viewportSize.width - queryData.padding.horizontal,
          viewportHeight: viewportSize.height - appBar.preferredSize.height - queryData.padding.vertical,
          // bundle: KrakenBundle.fromUrl('assets://assets/bundle.js'),
          // hub server 后 ip 更换成 本地
          // bundle: KrakenBundle.fromUrl('https://pre.t.youku.com/yep/page/kraken/m_pre/08a5sb2xno?isNeedBaseImage=1'),
          bundle: KrakenBundle.fromUrl('http://30.7.203.92:3000/build/demo.init.js'),
          // bundle: KrakenBundle.fromUrl('https://t.youku.com/yep/page/kraken/m/j73sp0s55m'),
          // bundle: KrakenBundle.fromUrl('http://30.77.124.31:3000/build/demo.init.js'),
        ),
    ));
  }
}
