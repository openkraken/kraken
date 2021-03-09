describe('MethodChannel', () => {
  it('invokeMethod', async () => {
    let result = await kraken.methodChannel.invokeMethod('helloworld', 'abc');
    // TEST App will return method string
    expect(result).toBe('method: helloworld');
  });

  it('setMethodHandler', async (done) => {
    kraken.methodChannel.setMethodCallHandler((method: string, args: any[]) => {
      expect(method).toBe('helloworld');
      expect(args).toEqual(['abc']);
      done();
    });
    let result = await kraken.methodChannel.invokeMethod('helloworld', 'abc');
    expect(result).toBe('method: helloworld');
  });

  it('setMethodCallHandler multi params', async (done) => {
    kraken.methodChannel.setMethodCallHandler((method: string, args: any[]) => {
      expect(method).toBe('helloworld');
      expect(args).toEqual(['abc', 1234, null, /* undefined will be converted to */ null, [], true, false, {name: 1}]);
      done();
    });
    let result = await kraken.methodChannel.invokeMethod('helloworld', 'abc', 1234, null, undefined, [], true, false, {name: 1});
    expect(result).toBe('method: helloworld');
  });
});
