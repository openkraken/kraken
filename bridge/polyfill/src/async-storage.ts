/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

import { webf } from './webf';

export const asyncStorage = {
  getItem(key: number | string) {
    return new Promise((resolve, reject) => {
      webf.invokeModule('AsyncStorage', 'getItem', String(key), (e, data) => {
        if (e) return reject(e);
        resolve(data == null ? '' : data);
      });
    });
  },
  setItem(key: number | string, value: number | string) {
    return new Promise((resolve, reject) => {
      webf.invokeModule('AsyncStorage', 'setItem', [String(key), String(value)], (e, data) => {
        if (e) return reject(e);
        resolve(data);
      });
    });
  },
  removeItem(key: number | string) {
    return new Promise((resolve, reject) => {
      webf.invokeModule('AsyncStorage', 'removeItem', String(key), (e, data) => {
        if (e) return reject(e);
        resolve(data);
      });
    });
  },
  clear() {
    return new Promise((resolve, reject) => {
      webf.invokeModule('AsyncStorage', 'clear', '', (e, data) => {
        if (e) return reject(e);
        resolve(data);
      });
    });
  },
  getAllKeys() {
    return new Promise((resolve, reject) => {
      webf.invokeModule('AsyncStorage', 'getAllKeys', '', (e, data) => {
        if (e) return reject(e);
        resolve(data);
      });
    });
  },
  length(): Promise<number> {
    return new Promise((resolve, reject) => {
      webf.invokeModule('AsyncStorage', 'length', '', (e, data) => {
        if (e) return reject(e);
        resolve(data);
      });
    });
  }
}
