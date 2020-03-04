import { krakenInvokeModule } from './kraken';

const asyncStorage = {
  getItem(key: string) {
    return new Promise((resolve) => {
      krakenInvokeModule(`["AsyncStorage.getItem", ["${key}"]]`, (value) => {
        resolve(value);
      });
    });
  },
  setItem(key: string, value: string) {
    return new Promise((resolve) => {
      krakenInvokeModule(`["AsyncStorage.setItem", ["${key}", "${value}"]]`, () => {
        resolve();
      });
    });
  },
  removeItem(key: string) {
    return new Promise((resolve) => {
      krakenInvokeModule(`["AsyncStorage.removeItem", ["${key}"]]`, () => {
        resolve();
      });
    });
  },
  clear() {
    return new Promise((resolve) => {
      krakenInvokeModule(`["AsyncStorage.clear"]`, () => {
        resolve();
      });
    });
  },
  getAllKeys() {
    return new Promise((resolve) => {
      krakenInvokeModule(`["AsyncStorage.getAllKeys"]`, (json) => {
        resolve(JSON.parse(json));
      });
    });
  }
}

Object.defineProperty(global, 'asyncStorage', {
  enumerable: true,
  writable: false,
  value: asyncStorage,
  configurable: false
});
