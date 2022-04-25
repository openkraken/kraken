describe('script element', () => {
  it('should work with src', async (done) => {
    const p = <p>Should see hello below:</p>;
    document.body.appendChild(p);
    var x = document.createElement('script');
    x.src = 'assets:///assets/hello.js';
    document.head.appendChild(x);
    x.onload = async () => {
      await snapshot();
      done();
    };
  });

  it('load failed with error event', (done) => {
    const script = document.createElement('script');
    document.body.appendChild(script);
    script.onerror = () => {
      done();
    };
    script.src = 'http://g.alicdn.com/path/to/404';
  });

  it('async script execute in delayed order', async (done) => {
    const script1 = document.createElement('script');
    script1.async = true;
    script1.src = 'assets:///assets/defineA.js';
    document.body.appendChild(script1);

    const script2 = document.createElement('script');
    script2.async = true;
    script2.src = 'assets:///assets/defineB.js';
    document.body.appendChild(script2);

    script1.onload = () => {
      // expect bundle B has already loaded.
      expect(window.A).toEqual('A');
      expect(window.B).toEqual('B');

      expect(window.bundleBLoadTime - window.bundleALoadTime > 0).toEqual(true);
      done();
    };
  });
});
