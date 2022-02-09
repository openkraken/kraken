import { kraken } from './kraken';
import connection from './connection';

export const navigator = {
  connection,
  // UA is read-only.
  get userAgent() {
    return kraken.invokeModule('Navigator', 'getUserAgent');
  },
  get platform() {
    return kraken.invokeModule('Navigator', 'getPlatform');
  },
  get language() {
    return kraken.invokeModule('Navigator', 'getLanguage');
  },
  get languages() {
    return JSON.parse(kraken.invokeModule('Navigator', 'getLanguages'));
  },
  get appName() {
    return kraken.invokeModule('Navigator', 'getAppName');
  },
  get appVersion() {
    return kraken.invokeModule('Navigator', 'getAppVersion');
  },
  get hardwareConcurrency() {
    const logicalProcessors = kraken.invokeModule('Navigator', 'getHardwareConcurrency');
    return parseInt(logicalProcessors);
  },
  clipboard: {
    readText() {
      return new Promise((resolve, reject) => {
        kraken.invokeModule('Clipboard', 'readText', null, (e, data) => {
          if (e) {
            return reject(e);
          }
          resolve(data);
        });
      });
    },
    writeText(text: string) {
      return new Promise((resolve, reject) => {
        kraken.invokeModule('Clipboard', 'writeText', String(text), (e, data) => {
          if (e) {
            return reject(e);
          }
          resolve(data);
        });
      });
    }
  }
}
