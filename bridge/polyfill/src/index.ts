import { console } from './console';
import { document } from './document';
import { requestAnimationFrame } from './document/animation-frame';
import { WebSocket } from './websocket';
import { fetch, Request, Response, Headers } from './fetch';
import { matchMedia } from './match-media';
import { location } from './location';
import { navigator } from './navigator';
import { XMLHttpRequest } from './xhr';
import { Blob } from './blob';
import { asyncStorage } from './async-storage';
import { URLSearchParams } from './url-search-params';
import { URL } from './url';
import { Performance, performance } from './performance';
import { kraken } from './kraken';
import { MQTT } from './mqtt';
import { windowExtension } from './window';

Object.assign(window, windowExtension);
Object.defineProperties(window, {
  addEventListener: {
    get() {
      return windowExtension.addEventListener.bind(windowExtension);
    }
  },
  removeEventListener: {
    get() {
      return windowExtension.removeEventListener.bind(windowExtension);
    }
  },
  dispatchEvent: {
    get() {
      return windowExtension.dispatchEvent.bind(windowExtension);
    }
  }
});
defineGlobalProperty('console', console);
defineGlobalProperty('requestAnimationFrame', requestAnimationFrame);
defineGlobalProperty('document', document);
defineGlobalProperty('WebSocket', WebSocket);
defineGlobalProperty('Request', Request);
defineGlobalProperty('Response', Response);
defineGlobalProperty('Headers', Headers);
defineGlobalProperty('fetch', fetch);
defineGlobalProperty('matchMedia', matchMedia);
defineGlobalProperty('location', location);
defineGlobalProperty('navigator', navigator);
defineGlobalProperty('XMLHttpRequest', XMLHttpRequest);
defineGlobalProperty('Blob', Blob);
defineGlobalProperty('asyncStorage', asyncStorage);
defineGlobalProperty('URLSearchParams', URLSearchParams);
defineGlobalProperty('URL', URL);
defineGlobalProperty('Performance', Performance);
defineGlobalProperty('performance', performance);
defineGlobalProperty('kraken', kraken);
defineGlobalProperty('MQTT', MQTT);

function defineGlobalProperty(key: string, value: any) {
  Object.defineProperty(globalThis, key, {
    value: value,
    enumerable: true,
    writable: false,
    configurable: false
  });
}


