import {privateKraken} from './types';
import {methodChannel} from './method_channel';

class Kraken {
  public methodChannel = methodChannel;
  constructor() {
    Object.assign(this, privateKraken)
  }
}

Object.defineProperty(global, 'kraken', {
  value: new Kraken(),
  configurable: false,
  writable: false,
  enumerable: true
});