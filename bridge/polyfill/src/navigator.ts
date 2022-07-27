/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

import { webf } from './webf';
import connection from './connection';

export const navigator = {
  connection,
  // UA is read-only.
  get userAgent() {
    return webf.invokeModule('Navigator', 'getUserAgent');
  },
  get platform() {
    return webf.invokeModule('Navigator', 'getPlatform');
  },
  get language() {
    return webf.invokeModule('Navigator', 'getLanguage');
  },
  get languages() {
    return JSON.parse(webf.invokeModule('Navigator', 'getLanguages'));
  },
  get appName() {
    return webf.invokeModule('Navigator', 'getAppName');
  },
  get appVersion() {
    return webf.invokeModule('Navigator', 'getAppVersion');
  },
  get hardwareConcurrency() {
    const logicalProcessors = webf.invokeModule('Navigator', 'getHardwareConcurrency');
    return parseInt(logicalProcessors);
  },
  clipboard: {
    readText() {
      return new Promise((resolve, reject) => {
        webf.invokeModule('Clipboard', 'readText', null, (e, data) => {
          if (e) {
            return reject(e);
          }
          resolve(data);
        });
      });
    },
    writeText(text: string) {
      return new Promise((resolve, reject) => {
        webf.invokeModule('Clipboard', 'writeText', String(text), (e, data) => {
          if (e) {
            return reject(e);
          }
          resolve(data);
        });
      });
    }
  }
}
