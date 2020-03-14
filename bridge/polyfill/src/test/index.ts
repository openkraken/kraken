import expect from 'expect';

Object.defineProperty(global, 'expect', {
  configurable: false,
  enumerable: true,
  writable: false,
  value: expect
});