describe('MethodChannel', () => {
  it('addMethodCallHandler multi params', async (done) => {
    kraken.methodChannel.addMethodCallHandler((method: string, args: any[]) => {
      expect(method).toBe('helloworld');
      expect(args).toEqual(['abc', 1234, null, /* undefined will be converted to */ null, [], true, false, {name: 1}]);
      done();
    });
    let result = await kraken.methodChannel.invokeMethod('helloworld', 'abc', 1234, null, undefined, [], true, false, {name: 1});
    expect(result).toBe('method: helloworld');
  });

  it('invokeMethod', async () => {
    let result = await kraken.methodChannel.invokeMethod('helloworld', 'abc');
    // TEST App will return method string
    expect(result).toBe('method: helloworld');
  });

  it('addMethodCallHandler', async (done) => {
    kraken.methodChannel.addMethodCallHandler((method: string, args: any[]) => {
      expect(method).toBe('helloworld');
      expect(args).toEqual(['abc']);
      done();
    });
    let result = await kraken.methodChannel.invokeMethod('helloworld', 'abc');
    expect(result).toBe('method: helloworld');
  });


  it('removeMethodCallHandler', async (done: DoneFn) => {
    var handler = (method: string, args: any[]) => {
      done.fail('should not execute here.');
    };
    kraken.methodChannel.addMethodCallHandler(handler);
    kraken.methodChannel.removeMethodCallHandler(handler);
    let result = await kraken.methodChannel.invokeMethod('helloworld', 'abc');
    expect(result).toBe('method: helloworld');
    done();
  });

  it('addMethodCallHandler multi params with multi handler', async (done) => {
    let handlerCount = 0;
    kraken.methodChannel.addMethodCallHandler((method: string, args: any[]) => {
      handlerCount++;
      expect(method).toBe('helloworld');
      expect(args).toEqual(['abc', 1234, null, /* undefined will be converted to */ null, [], true, false, {name: 1}]);
      if(handlerCount == 2) {
        done();
      }
    });
    kraken.methodChannel.addMethodCallHandler((method: string, args: any[]) => {
      handlerCount++;
      expect(method).toBe('helloworld');
      expect(args).toEqual(['abc', 1234, null, /* undefined will be converted to */ null, [], true, false, {name: 1}]);
      if (handlerCount == 2) {
        done();
      }
    });
    let result = await kraken.methodChannel.invokeMethod('helloworld', 'abc', 1234, null, undefined, [], true, false, {name: 1});
    expect(result).toBe('method: helloworld');
    expect(handlerCount).toBe(2);
  });
});
