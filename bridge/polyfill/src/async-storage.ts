import { kraken } from './kraken';

export const asyncStorage = {
  getItem(key: number | string) {
    return new Promise((resolve, reject) => {
      kraken.invokeModule('AsyncStorage', 'getItem', String(key), (e, data) => {
        if (e) return reject(e);
        resolve(data == null ? '' : data);
      });
    });
  },
  setItem(key: number | string, value: number | string) {
    return new Promise((resolve, reject) => {
      kraken.invokeModule('AsyncStorage', 'setItem', [String(key), String(value)], (e, data) => {
        if (e) return reject(e);
        resolve(data);
      });
    });
  },
  removeItem(key: number | string) {
    return new Promise((resolve, reject) => {
      kraken.invokeModule('AsyncStorage', 'removeItem', String(key), (e, data) => {
        if (e) return reject(e);
        resolve(data);
      });
    });
  },
  clear() {
    return new Promise((resolve, reject) => {
      kraken.invokeModule('AsyncStorage', 'clear', '', (e, data) => {
        if (e) return reject(e);
        resolve(data);
      });
    });
  },
  getAllKeys() {
    return new Promise((resolve, reject) => {
      kraken.invokeModule('AsyncStorage', 'getAllKeys', '', (e, data) => {
        if (e) return reject(e);
        resolve(data);
      });
    });
  },
  length(): Promise<number> {
    return new Promise((resolve, reject) => {
      kraken.invokeModule('AsyncStorage', 'length', '', (e, data) => {
        if (e) return reject(e);
        resolve(data);
      });
    });
  }
}
