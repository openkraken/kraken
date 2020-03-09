describe('setTimeout', function () {
  it('resolve after 1 seconds', () => {
    return new Promise((resolve) => {
      setTimeout(() => {
        resolve();
      }, 1000);
    });
  });
});