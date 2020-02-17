import { krakenModuleManager } from './kraken';

const navigator = {
  connection: {
    getConnectivity() {
      return new Promise((resolve) => {
        krakenModuleManager('["getConnectivity"]', (json) => {
          resolve(JSON.parse(json));
        });
      });
    }
  }
}

Object.defineProperty(global, 'navigator', {
  enumerable: true,
  writable: false,
  value: navigator,
  configurable: false
});
