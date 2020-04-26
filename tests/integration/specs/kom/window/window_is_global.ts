describe('window-is-global', () => {
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
});
