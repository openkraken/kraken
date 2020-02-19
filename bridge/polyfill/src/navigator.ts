import { krakenInvokeModule, krakenModuleListener } from './kraken';

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
  }
}

Object.defineProperty(global, 'navigator', {
  enumerable: true,
  writable: false,
  value: navigator,
  configurable: false
});
