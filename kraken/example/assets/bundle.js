 kraken.methodChannel.setMethodCallHandler((method, args) => {
    console.log(args);
    });
    kraken.methodChannel.invokeMethod('helloworld', 'abc', 1234, null, undefined, [], true, false, {name: 1});
