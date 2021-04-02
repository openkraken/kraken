import 'es6-promise/dist/es6-promise.auto';
import { console } from './kom/console';
import { WebSocket } from './modules/websocket';
import { fetch, Request, Response, Headers } from './modules/fetch';
import { matchMedia } from './kom/match-media';
import { location } from './kom/location';
import { navigator } from './kom/navigator';
import { XMLHttpRequest } from './modules/xhr';
import { asyncStorage } from './modules/async-storage';
import { URLSearchParams } from './kom/url-search-params';
import { URL } from './kom/url';
import { kraken } from './kom/kraken';
import { history } from './kom/history';

defineGlobalProperty('console', console);
defineGlobalProperty('WebSocket', WebSocket);
defineGlobalProperty('Request', Request);
defineGlobalProperty('Response', Response);
defineGlobalProperty('Headers', Headers);
defineGlobalProperty('fetch', fetch);
defineGlobalProperty('matchMedia', matchMedia);
defineGlobalProperty('location', location);
defineGlobalProperty('navigator', navigator);
defineGlobalProperty('__history__', history);
defineGlobalProperty('XMLHttpRequest', XMLHttpRequest);
defineGlobalProperty('asyncStorage', asyncStorage);
defineGlobalProperty('URLSearchParams', URLSearchParams);
defineGlobalProperty('URL', URL);
defineGlobalProperty('kraken', kraken);

function defineGlobalProperty(key: string, value: any) {
  Object.defineProperty(globalThis, key, {
    value: value,
    enumerable: true,
    writable: false,
    configurable: false
  });
}

// // Unhandled global promise handler used by JS Engine.
// // @ts-ignore
// window.__global_unhandled_promise_handler__ = function (promise, reason) {
//   // @ts-ignore
//   const errorEvent = new ErrorEvent({
//     message: reason.message,
//     error: reason
//   });
//   // @ts-ignore
//   const rejectionEvent = new PromiseRejectionEvent({
//     promise,
//     reason
//   });
//   // @ts-ignore
//   window.dispatchEvent(rejectionEvent);
//   // @ts-ignore
//   window.dispatchEvent(errorEvent);
// };

// Global error handler used by JS Engine
// // @ts-ignore
// window.__global_onerror_handler__ = function (error) {
//   // @ts-ignore
//   const event = new ErrorEvent({
//     error: error,
//     message: error.message,
//     lineno: error.line
//   });
//   // @ts-ignore
//   window.dispatchEvent(event);
// };

// default unhandled project handler
// window.addEventListener('unhandledrejection', (event) => {
//   console.error('Unhandled Promise Rejection: ' + event.reason);
// });
