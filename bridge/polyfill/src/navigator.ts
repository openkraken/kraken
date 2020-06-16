import { krakenInvokeModule, privateKraken } from './bridge';
import geolocation from './geolocation';
import connection from './connection';
import { vibrate } from './vibration';

export const navigator = {
  vibrate,
  connection,
  geolocation,
  // UA is read-only.
  get userAgent() {
    // Rule: @product/@productSub (@platform; @appName/@appVersion)
    const product = `${privateKraken.product}/${privateKraken.productSub}`;

    // comment is extra info injected by Shell.
    const comment = privateKraken.comment;
    return `${product} (${privateKraken.platform}; ${privateKraken.appName}/${privateKraken.appVersion})${comment ? ' ' + comment : ''}`;
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
