import { krakenInvokeModule, krakenModuleListener } from './kraken';

let map: {};
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
      // TODO: should only register one global module listener avoid repeat JSON parse
      krakenModuleListener(message => {
        let parsed = JSON.parse(message);
        const type = parsed[0];
        if (type === 'onConnectivityChanged') {
          const event = parsed[1];  
          listener(event);
        }
      });
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
        } else if(error != null) {
          error(result);
        }
      });
    },
    watchPosition(success: (data: any) => void, error?: (error: any) => void, options?: any) {
      const watchId = krakenInvokeModule(`["watchPosition", [${JSON.stringify(options)}]]`);
      map[watchId] = {success: success, error: error};
      // TODO: should only register one global module listener avoid repeat JSON parse
      krakenModuleListener(json => {
        let parsed = JSON.parse(json);
        const type = parsed[0];
        if (type === 'watchPosition') {
          const result = parsed[1];
          if (map[watchId]) {
            if (result['coords'] != null) {
              map[watchId]['success'](result);
            } else if(error != null) {
              map[watchId]['error'](result);
            }
          }
        }
      });
      return parseInt(watchId);
    },
    clearWatch(id: number) {
      delete map[id];
      if (Object.keys(map).length === 0) {
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
