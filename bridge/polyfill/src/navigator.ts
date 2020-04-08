import { krakenInvokeModule, privateKraken } from './types';

export const positionWatcherMap = new Map<string, any>();
export let onConnectivityChangeListener: (data: Object) => any;

const navigator = {
  // UA is read-only.
  get userAgent() {
    // Rule: @product/@productSub (@platform; @appName/@appVersion)
    const product = `${privateKraken.product}/${privateKraken.productSub}`;

    // comment is extra info injected by Shell.
    const comment = privateKraken.comment;
    return `${product} (${privateKraken.platform}; ${privateKraken.appName}/${privateKraken.appVersion})${comment ? ' ' + comment : ''}`;
  },
  connection: {
    getConnectivity() {
      return new Promise((resolve) => {
        krakenInvokeModule('["Connection","getConnectivity"]', (json) => {
          resolve(JSON.parse(json));
        });
      });
    },
    set onchange(listener: (data: Object) => any) {
      onConnectivityChangeListener = listener;
      // TODO: should remove old listener when onchange reset with a null listener
      krakenInvokeModule('["Connection","onConnectivityChanged"]');
    }
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
  geolocation: {
    getCurrentPosition(success: (data: any) => void, error?: (error: any) => void, options?: any) {
      let optionsStr = '';
      if (options != null) {
        optionsStr = JSON.stringify(options);
      }
      krakenInvokeModule(`["Geolocation","getCurrentPosition", [${optionsStr}]]`, (json) => {
        let result = JSON.parse(json);
        if (result['coords'] != null) {
          success(result);
        } else if (error != null) {
          error(result);
        }
      });
    },
    watchPosition(success: (data: any) => void, error?: (error: any) => void, options?: any) {
      let optionsStr = '';
      if (options != null) {
        optionsStr = JSON.stringify(options);
      }
      const watchId = krakenInvokeModule(`["Geolocation","watchPosition", [${optionsStr}]]`);
      positionWatcherMap.set(watchId, { success: success, error: error });
      return parseInt(watchId);
    },
    clearWatch(id: number) {
      positionWatcherMap.delete(id.toString());
      if (positionWatcherMap.size === 0) {
        krakenInvokeModule(`["Geolocation","clearWatch"]`);
      }
    }
  }
}

Object.defineProperty(global, 'navigator', {
  enumerable: true,
  writable: false,
  value: navigator,
  configurable: false
});
