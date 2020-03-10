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
      setInterval(null);
      throw new Error('setInterval: parameter 1 is not an function should to throw');
    } catch (e) {
    }
  });

  it('second param not number will throw', () => {
    try {
      setInterval(() => {
      }, []);
      throw new Error('setInterval: parameter 2 is not an number should be throw');
    } catch (e) {
    }
  });
});