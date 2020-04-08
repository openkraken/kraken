import {methodChannel} from './method-channel';

Object.defineProperty(global, 'kraken', {
  value: {
    methodChannel,
  },
  configurable: false,
  writable: false,
  enumerable: true
});