const startTime = performance.now();

describe('Performance', () => {
  it('timeOrigin', () => {
    expect(typeof performance.timeOrigin).toEqual('number');
  });

  it('now', (done) => {
    const now = performance.now();

    setTimeout(() => {
      const current = performance.now();
      expect(current - now).toBeGreaterThanOrEqual(300);
      done();
    }, 300);
  });

  it('init startTime should less than 1000', () => {
    expect(startTime).toBeLessThan(1000);
  });
});
