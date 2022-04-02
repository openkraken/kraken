describe('Screen', () => {

  it('basic', () => {
    expect(screen !== undefined).toEqual(true);
    expect(window.screen).toEqual(screen);
  });

  it('width', () => {
    expect(typeof screen.width).toEqual('number');
    expect(screen.width > 0).toEqual(true);
  });

  it('height', () => {
    expect(typeof screen.height).toEqual('number');
    expect(screen.height > 0).toEqual(true);
  });

  it('availWidth', () => {
    expect(typeof screen.availWidth).toEqual('number');
    expect(screen.availWidth > 0).toEqual(true);
  });

  it('availHeight', () => {
    expect(typeof screen.availHeight).toEqual('number');
    expect(screen.availHeight > 0).toEqual(true);
  });
});
