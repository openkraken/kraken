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
import { windowMixin } from './window';

Object.assign(window, windowMixin);
addGlobalObject('console', console);
addGlobalObject('requestAnimationFrame', requestAnimationFrame);
addGlobalObject('document', document);
addGlobalObject('WebSocket', WebSocket);
addGlobalObject('Request', Request);
addGlobalObject('Response', Response);
addGlobalObject('Headers', Headers);
addGlobalObject('fetch', fetch);
addGlobalObject('matchMedia', matchMedia);
addGlobalObject('location', location);
addGlobalObject('navigator', navigator);
addGlobalObject('XMLHttpRequest', XMLHttpRequest);
addGlobalObject('Blob', Blob);
addGlobalObject('asyncStorage', asyncStorage);
addGlobalObject('URLSearchParams', URLSearchParams);
addGlobalObject('URL', URL);
addGlobalObject('Performance', Performance);
addGlobalObject('performance', performance);
addGlobalObject('kraken', kraken);
addGlobalObject('MQTT', MQTT);

function addGlobalObject(key: string, value: any) {
  Object.defineProperty(globalThis, key, {
    value: value,
    enumerable: true,
    writable: false,
    configurable: false
  });
}


