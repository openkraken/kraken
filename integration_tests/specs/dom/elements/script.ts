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
    script.src = 'http://127.0.0.1/path/to/a/file';
  });

  it('async script execute in delayed order', async (done) => {
    const scriptA = document.createElement('script');
    scriptA.async = true;
    scriptA.src = 'assets:///assets/defineA.js';

    const scriptB = document.createElement('script');
    scriptB.src = 'assets:///assets/defineB.js';

    document.body.appendChild(scriptA);
    document.body.appendChild(scriptB);

    scriptA.onload = () => {
      // expect bundle B has already loaded.
      expect(window.A).toEqual('A');
      expect(window.B).toEqual('B');

      // Bundle B load earlier than A.
      expect(window.bundleALoadTime - window.bundleBLoadTime > 0).toEqual(true);
      done();
    };
  });
});
