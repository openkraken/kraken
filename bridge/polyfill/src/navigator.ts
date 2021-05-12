import { kraken } from './kraken';
import connection from './connection';
import { vibrate } from './vibration';

export const navigator = {
  vibrate,
  connection,
  // UA is read-only.
  get userAgent() {
    return kraken.userAgent;
  },
  get hardwareConcurrency() {
    const logicalProcessors = kraken.invokeModule('DeviceInfo', 'getHardwareConcurrency');
    return parseInt(logicalProcessors);
  },
  getDeviceInfo() {
    return new Promise((resolve, reject) => {
      kraken.invokeModule('DeviceInfo', 'getDeviceInfo', null, (e, data) => {
        if (e) {
          return reject(e);
        }
        resolve(data);
      });
    });
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
