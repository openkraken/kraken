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

  it('init startTime should less than 2000', () => {
    expect(startTime).toBeLessThan(2000);
  });

  it('clearMarks', () => {
    performance.mark('abc');
    performance.mark('efg');
    let entries = performance.getEntries();
    let hasAbc = entries.some(e => e.name === 'abc');
    let hasEfg = entries.some(e => e.name === 'efg');
    expect(hasAbc).toBe(true);
    expect(hasEfg).toBe(true);
    performance.clearMarks('efg');
    entries = performance.getEntries();
    hasAbc = entries.some(e => e.name === 'abc');
    hasEfg = entries.some(e => e.name === 'efg');
    expect(hasAbc).toBe(true);
    expect(hasEfg).toBe(false);
    performance.clearMarks();
  });
});
