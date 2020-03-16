describe('setTimeout', function () {
  it('resolve after 100ms', () => {
    let startTime = Date.now();
    return new Promise((resolve) => {
      setTimeout(() => {
        let duration = Date.now() - startTime;
        // 10ms delay accepted
        expect((duration - 100) < 10).toBe(true);
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
    expect(() => {
      // @ts-ignore
      setTimeout(null);
    }).toThrowError();
  });

  it('second param not number will throw', () => {
    expect(() => {
      setTimeout(() => {
        // @ts-ignore
      }, []);
    }).toThrowError();
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
    expect(() => {
      // @ts-ignore
      setInterval(null);
    }).toThrowError();
  });

  it('second param not number will throw', () => {
    expect(() => {
      setInterval(() => {
        // @ts-ignore
      }, []);
    }).toThrowError();
  });
});