import assert from 'assert';

Object.defineProperty(global, 'assert', {
  configurable: false,
  enumerable: true,
  writable: false,
  value: assert
});