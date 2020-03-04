import { krakenInvokeModule } from './kraken';

export const positionWatcherMap = new Map<string, any>();
export let onConnectivityChangeListener: (data: Object) => any;

const navigator = {
  connection: {
    getConnectivity() {
      return new Promise((resolve) => {
        krakenInvokeModule('["getConnectivity"]', (json) => {
          resolve(JSON.parse(json));
        });
      });
    },
    set onchange(listener: (data: Object) => any) {
      onConnectivityChangeListener = listener;
      // TODO: should remove old listener when onchange reset with a null listener
      krakenInvokeModule('["onConnectivityChanged"]');
    }
  },
  get hardwareConcurrency() {
    const logicalProcessors = krakenInvokeModule('["getHardwareConcurrency"]');
    return parseInt(logicalProcessors);
  },
  getDeviceInfo() {
    return new Promise((resolve) => {
      krakenInvokeModule('["getDeviceInfo"]', (json) => {
        resolve(JSON.parse(json));
      });
    });
  },
  geolocation: {
    getCurrentPosition(success: (data: any) => void, error?: (error: any) => void, options?: any) {
      krakenInvokeModule(`["getCurrentPosition", [${JSON.stringify(options)}]]`, (json) => {
        let result = JSON.parse(json);
        if (result['coords'] != null) {
          success(result);
        } else if (error != null) {
          error(result);
        }
      });
    },
    watchPosition(success: (data: any) => void, error?: (error: any) => void, options?: any) {
      const watchId = krakenInvokeModule(`["watchPosition", [${JSON.stringify(options)}]]`);
      positionWatcherMap.set(watchId, { success: success, error: error });
      return parseInt(watchId);
    },
    clearWatch(id: number) {
      positionWatcherMap.delete(id.toString());
      if (positionWatcherMap.size === 0) {
        krakenInvokeModule(`["clearWatch"]`);
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
