describe('window', () => {
  it('window equal to globalThis', () => {
    expect(window).toBe(globalThis as any);
  });

  it('has kraken defined', () => {
    // @ts-ignore
    expect(typeof window.kraken).toBe('object');
  });

  it('equal to this', () => {
    function f() {
      // @ts-ignore
      expect(this).toBe(window);
    }

    f();
  });

  it('can set property', () => {
    // @ts-ignore
    window.foo = 'foo';
    // @ts-ignore
    expect(window.foo).toBe('foo');
  });

  it('set property are sample with set into global', () => {
    // @ts-ignore
    window.abc = '1234';
    // @ts-ignore
    expect(abc).toBe('1234');
    expect(globalThis.abc).toBe('1234');
    // @ts-ignore
    expect(window.abc).toBe('1234');
  });

  it('onload should in window', () => {
    expect('onload' in window).toBe(true);
  });

  it('window.self should be self', () => {
    expect(window.self).toBe(window);
  });

  it('window should work with addEventListener', async (done) => {
    const div = document.createElement('div');
    div.style.width = '100px';
    div.style.height = '100px';
    document.body.appendChild(div);

    window.addEventListener('click', () => {
      done();
    });

    await simulateClick(10, 10);
  });
});
