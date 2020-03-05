import { krakenWindow } from './kraken';

Object.defineProperty(global, 'onload', {
  enumerable: true,
  configurable: false,
  set(fn: any) {
    krakenWindow.onLoad = fn;
  },
});

const WINDOW_PROPERTIES : Array<Array<any>> = [
  ['devicePixelRatio', () => krakenWindow.devicePixelRatio],
];

for (let i = 0; i < WINDOW_PROPERTIES.length; i++) {
  Object.defineProperty(global, WINDOW_PROPERTIES[i][0], {
    enumerable: true,
    configurable: false,
    get: WINDOW_PROPERTIES[i][1],
  });
}

Object.defineProperty(global, 'window', {
  enumerable: true,
  writable: false,
  configurable: false,
  value: global,
});
Object.setPrototypeOf(window, global);
