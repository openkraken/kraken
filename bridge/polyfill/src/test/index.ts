import assert from 'assert';

type It = (name: string, fn: (done: (status?: any) => void) => any) => {};

declare const __kraken_it__: It;
const krakenIt = __kraken_it__;

function it(name: string, fn: any) {
  krakenIt(name, async done => {
    try {
      await Promise.resolve(fn());
      done();
    } catch (e) {
      done(e);
    }
  });
}

Object.defineProperty(global, 'it', {
  configurable: false,
  enumerable: true,
  writable: false,
  value: it
});

Object.defineProperty(global, 'assert', {
  configurable: false,
  enumerable: true,
  writable: false,
  value: assert
});