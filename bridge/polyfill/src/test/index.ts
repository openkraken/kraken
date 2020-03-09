import assert from 'assert';

type It = (name: string, fn: (done: (status?: any) => void) => any) => {};

declare const __kraken_it__: It;
const krakenIt = __kraken_it__;

function isPromise(obj: any) {
  return !!obj && (typeof obj === 'object' || typeof obj === 'function') && typeof obj.then === 'function';
}

function It(name: string, fn: any) {
  krakenIt(name, done => {
    let ret;
    try {
      ret = fn();
      if (isPromise(ret)) {
        ret.then(() => {
          done();
        }).catch((err: any) => {
          done(err);
        });
      } else {
        done();
      }
    } catch (e) {
      done(e);
    }
  });
}

Object.defineProperty(global, 'it', {
  configurable: false,
  enumerable: true,
  writable: false,
  value: It
});

Object.defineProperty(global, 'assert', {
  configurable: false,
  enumerable: true,
  writable: false,
  value: assert
});