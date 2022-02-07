import 'es6-promise/dist/es6-promise.auto';
// import './dom';
// import './query-selector';
import { console } from './console';
// import { fetch, Request, Response, Headers } from './fetch';
// import { matchMedia } from './match-media';
// import { location } from './location';
// import { history } from './history';
// import { navigator } from './navigator';
// import { XMLHttpRequest } from './xhr';
// import { asyncStorage } from './async-storage';
// import { URLSearchParams } from './url-search-params';
// import { URL } from './url';
// import { kraken } from './kraken';
// import { ErrorEvent, PromiseRejectionEvent } from './events';

// defineGlobalProperty('ErrorEvent', ErrorEvent);
// defineGlobalProperty('PromiseRejectionEvent', PromiseRejectionEvent);
defineGlobalProperty('console', console);
// defineGlobalProperty('Request', Request);
// defineGlobalProperty('Response', Response);
// defineGlobalProperty('Headers', Headers);
// defineGlobalProperty('fetch', fetch);
// defineGlobalProperty('matchMedia', matchMedia);
// defineGlobalProperty('location', location);
// defineGlobalProperty('history', history);
// defineGlobalProperty('navigator', navigator);
// defineGlobalProperty('XMLHttpRequest', XMLHttpRequest);
// defineGlobalProperty('asyncStorage', asyncStorage);
// defineGlobalProperty('URLSearchParams', URLSearchParams);
// defineGlobalProperty('URL', URL);
// defineGlobalProperty('kraken', kraken);
// defineGlobalProperty('ErrorEvent', ErrorEvent);

function defineGlobalProperty(key: string, value: any, isEnumerable: boolean = true) {
  Object.defineProperty(globalThis, key, {
    value: value,
    enumerable: isEnumerable,
    writable: true,
    configurable: true
  });
}
