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
      // @ts-ignore
      setTimeout(null);
      throw new Error('setTimeout: parameter 1 is not an function should to throw');
    } catch (e) {
    }
  });

  it('second param not number will throw', () => {
    try {
      setTimeout(() => {
        // @ts-ignore
      }, []);
      throw new Error('setTimeout: parameter 2 is not an number should be throw');
    } catch (e) {
    }
  });
});

describe('setInterval', function () {
  it('trigger 5 times and stop', () => {
    return new Promise((resolve, reject) => {
      let count = 0;
      let timer = setInterval(() => {
        count++;
        if (count > 5) {
          clearTimeout(timer);
          resolve();
        }
      }, 10);
      setTimeout(() => {
        reject('setInterval execute time out!');
      }, 100);
    });
  });

  it('first param not function will throw', () => {
    try {
      // @ts-ignore
      setInterval(null);
      throw new Error('setInterval: parameter 1 is not an function should to throw');
    } catch (e) {
    }
  });

  it('second param not number will throw', () => {
    try {
      setInterval(() => {
        // @ts-ignore
      }, []);
      throw new Error('setInterval: parameter 2 is not an number should be throw');
    } catch (e) {
    }
  });
});