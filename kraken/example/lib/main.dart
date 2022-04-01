import 'dart:collection';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/devtools.dart';
import 'package:kraken_example/mock_prescript.dart';
import 'package:kraken_websocket/kraken_websocket.dart';


@pragma('vm:entry-point')
void top() => runApp( MyApp(title: 'Top VC',));

@pragma('vm:entry-point')
void bottom() => runApp( MyApp(title: 'Bottom VC',));

void main() {
  KrakenWebsocket.initialize();
  PaintingBinding.instance?.imageCache?.maximumSize = 0;
  PaintingBinding.instance?.imageCache?.maximumSizeBytes = 0;
  runApp(MyApp(title: 'First Page'));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final String? title;
  const MyApp({Key? key, this.title}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kraken Exp Root Page',
      // theme: ThemeData.dark(),
      home: MyTestHomePage(title: title??'First Page'),
    );
  }
}

class MyTestHomePage extends StatefulWidget {
  final String? title;
  final Color appbarColor = Colors.blue;
  MyTestHomePage({Key? key, this.title}) : super(key: key);
  @override
  State<MyTestHomePage> createState() => _MyTestHomePageState(title: title, appbarColor: appbarColor);
}

class _MyTestHomePageState extends State<MyTestHomePage> {
  late final String? title;
  final channel = const MethodChannel('devchannel');
  Color appbarColor = Colors.blue;
  _MyTestHomePageState({this.title, required this.appbarColor});

  Widget _getPushPage(BuildContext context) {
    if (title == 'Top VC') {
      return Scaffold(
        body: Center(
          child: ListView(
            children: [
              ElevatedButton(onPressed: () async {
                final s = await channel.invokeMethod('test1');
                print('get result $s');
              }, child: Text('Tap 1 Action')),
              Image.network('https://lmg.jj20.com/up/allimg/4k/s/02/21092423260Q119-0-lp.jpg'),
              Image.network('https://lmg.jj20.com/up/allimg/4k/s/02/210925005U45505-0-lp.jpg'),
              Image.network('https://lmg.jj20.com/up/allimg/4k/s/02/210925010H5N64-0-lp.jpg'),
              Image.network('https://lmg.jj20.com/up/allimg/4k/s/02/21092501141252E-0-lp.jpg'),
            ],
          ),
        ),
      );
    } else if (title == 'Bottom VC') {
      return Scaffold(
        body: Center(
          child: ListView(
            children: [
              ElevatedButton(onPressed: () async {
                final s = await channel.invokeMethod('test2');
                print('get result $s');
              }, child: Text('Tap 2 Action')),
              ElevatedButton(onPressed: () async {
                final s = await channel.invokeMethod('changeColor');
                print('get result $s');
                if (s.toString().isNotEmpty) {
                  final map = Map<String, dynamic>.from(s);
                  final new_color = Color.fromARGB(255, map['r'], map['g'], map['b']);
                  setState(() {
                    appbarColor = new_color;
                  });
                }
              }, child: Text('Get Color')),
              Image.network('https://lmg.jj20.com/up/allimg/4k/s/02/2109242301524006-0-lp.jpg'),
              Image.network('https://lmg.jj20.com/up/allimg/4k/s/02/210925004K030X-0-lp.jpg'),
              Image.network('https://lmg.jj20.com/up/allimg/4k/s/02/2109250122395325-0-lp.jpg'),
              Image.network('https://lmg.jj20.com/up/allimg/4k/s/02/2109250121133234-0-lp.jpg'),
            ],
          ),
        ),
      );
    } else {
      return MyBrowser(
        title: 'Kraken Page',
      );
    }
  }

  AppBar? _getAppBar() {
    if (title == 'First Page') {
      return null;
    }
    return AppBar(
      title: Text(title ?? 'MyHomePage'),
      backgroundColor: appbarColor,
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    print(appbarColor);
    return Scaffold(
      appBar: _getAppBar(),
      body: Center(
        //这是一个IOS风格材质的按钮，需要导入cupertino文件才能引用
          child: CupertinoButton(
              color: Colors.blue,
              child: Text('Push Kraken Page'),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Scaffold(
                          body: _getPushPage(context),
                          appBar: _getAppBar(),
                        )));
                        // builder: (context) => _getPushPage()));
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
          bundle: KrakenBundle.fromUrl('http://30.77.124.31:3000/build/demo.init.js'),
          // bundle: KrakenBundle.fromUrl('https://t.youku.com/yep/page/kraken/m/j73sp0s55m'),
          // bundle: KrakenBundle.fromUrl('http://30.77.124.31:3000/build/demo.init.js'),
        ),
    ));
  }
}
