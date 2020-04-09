import { krakenInvokeModule } from './bridge';

const TRUE = 'true';
const asyncStorage = {
  getItem(key: string) {
    return new Promise((resolve, reject) => {
      krakenInvokeModule(JSON.stringify(['AsyncStorage', 'getItem', [key]]), resolve);
    });
  },
  setItem(key: string, value: string) {
    return new Promise((resolve, reject) => {
      krakenInvokeModule(JSON.stringify(['AsyncStorage', 'setItem', [key, value]]), (ret) => {
        ret === TRUE ? resolve() : reject();
      });
    });
  },
  removeItem(key: string) {
    return new Promise((resolve, reject) => {
      krakenInvokeModule(JSON.stringify(['AsyncStorage', 'removeItem', [key]]), (ret) => {
        ret === TRUE ? resolve() : reject();
      });
    });
  },
  clear() {
    return new Promise((resolve, reject) => {
      krakenInvokeModule(`["AsyncStorage","clear"]`, (ret) => {
        ret === TRUE ? resolve() : reject();
      });
    });
  },
  getAllKeys() {
    return new Promise((resolve, reject) => {
      krakenInvokeModule(`["AsyncStorage","getAllKeys"]`, (json) => {
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
