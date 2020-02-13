import { krakenModuleManager } from './kraken';

const navigator = {
  connection: {
    checkConnectivity() {
      return new Promise((resolve) => {
        krakenModuleManager('["checkConnectivity"]', (json) => {
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
