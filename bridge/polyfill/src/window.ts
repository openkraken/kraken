import { krakenWindow } from './kraken';

Object.defineProperty(global, 'onload', {
  enumerable: true,
  configurable: false,
  set(fn: any) {
    krakenWindow.onLoad = fn;
  },
});

Object.defineProperty(global, 'devicePixelRatio', {
  enumerable: true,
  configurable: false,
  get() {
    return krakenWindow.devicePixelRatio;
  },
});

Object.defineProperty(global, 'window', {
  enumerable: true,
  writable: false,
  configurable: false,
  value: global,
});
