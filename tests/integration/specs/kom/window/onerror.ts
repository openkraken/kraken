xdescribe('window onerror', () => {
  it('window onerror default to null', () => {
    expect(window.onerror).toEqual(null);
  });

  it('window onerror works', (done) => {
    const ex = new Error('CustomErrorTest');
    window.onerror = function(event, sourceURL, line, column, error) {
      expect(window.onerror).toBe(arguments.callee);

      // Reset onerror.
      window.onerror = null;

      expect(error).toBe(ex);
      expect(sourceURL).toEqual(location.href);
      expect(event instanceof Event).toBeTrue();

      done();
    };
  });
});
