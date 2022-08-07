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
    script.src = 'http://example.com/404';
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
      expect(window.bundleALoadTime - window.bundleBLoadTime >= 0).toEqual(true);
      done();
    };
  });

  it('Waiting order for large script loaded', (done) => {
    const scriptLarge = document.createElement('script');
    scriptLarge.src = 'assets:///assets/large-script.js';

    const scriptSmall = document.createElement('script');
    scriptSmall.src = 'assets:///assets/defineA.js';

    function waitForLoad(script) {
      return new Promise((resolve) => {
        script.onload = () => {
          resolve();
        };
      });
    }

    document.body.appendChild(scriptLarge);
    document.body.appendChild(scriptSmall);

    Promise.all([
      waitForLoad(scriptLarge),
      waitForLoad(scriptSmall),
    ]).then(() => {
      // Bundle C load earlier than A.
      expect(window.bundleALoadTime - window.bundleCLoadTime >= 0).toEqual(true);
      done();
    });
  });
});
