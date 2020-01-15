import requestAnimationFrame from 'raf';

Object.defineProperty(global, 'requestAnimationFrame', {
  value: requestAnimationFrame,
  enumerable: true,
  configurable: false,
  writable: false
});
