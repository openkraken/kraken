import { krakenInvokeModule, privateKraken } from '../bridge';
import geolocation from '../modules/geolocation';
import connection from '../modules/connection';
import { vibrate } from '../modules/vibration';

export const navigator = {
  vibrate,
  connection,
  geolocation,
  // UA is read-only.
  get userAgent() {
    return privateKraken.userAgent;
  },
  get hardwareConcurrency() {
    const logicalProcessors = krakenInvokeModule('["DeviceInfo","getHardwareConcurrency"]');
    return parseInt(logicalProcessors);
  },
  getDeviceInfo() {
    return new Promise((resolve) => {
      krakenInvokeModule('["DeviceInfo","getDeviceInfo"]', (json) => {
        resolve(JSON.parse(json));
      });
    });
  },
  clipboard: {
    readText() {
      return new Promise((resolve) => {
        krakenInvokeModule(`["Clipboard","readText"]`, resolve);
      });
    },
    writeText(text: string) {
      return new Promise((resolve) => {
        krakenInvokeModule(JSON.stringify(['Clipboard', 'writeText', [String(text)]]), () => {
          // Return undefined
          resolve();
        });
      });
    }
  }
}
