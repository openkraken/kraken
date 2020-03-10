describe('setTimeout', function () {
  it('resolve after 1 seconds', () => {
    return new Promise((resolve) => {
      setTimeout(() => {
        resolve();
      }, 100);
    });
  });

  it('stop before resolved', () => {
    return new Promise((resolve, reject) => {
      let timer = setTimeout(() => {
        reject();
      }, 100);

      setTimeout(() => {
        resolve();
      }, 120);

      setTimeout(() => {
        clearTimeout(timer);
      }, 50);
    });
  });

  it('first param not function will throw', () => {
    try {
      setTimeout(null);
      throw new Error('setTimeout: parameter 1 is not an function should to throw');
    } catch (e) {}
  });

  it('second param not number will throw', () => {
    try {
      setTimeout(() => {}, []);
      throw new Error('setTimeout: parameter 2 is not an number should be throw');
    } catch (e) {}
  });
});