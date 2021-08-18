import 'es6-promise/dist/es6-promise.auto';
import './dom';
import { console } from './console';
import { WebSocket } from './websocket';
import { fetch, Request, Response, Headers } from './fetch';
import { matchMedia } from './match-media';
import { location } from './location';
import { navigator } from './navigator';
import { XMLHttpRequest } from './xhr';
import { asyncStorage } from './async-storage';
import { URLSearchParams } from './url-search-params';
import { URL } from './url';
import { kraken } from './kraken';
import { history } from './history';

defineGlobalProperty('console', console);
defineGlobalProperty('WebSocket', WebSocket);
defineGlobalProperty('Request', Request);
defineGlobalProperty('Response', Response);
defineGlobalProperty('Headers', Headers);
defineGlobalProperty('fetch', fetch);
defineGlobalProperty('matchMedia', matchMedia);
defineGlobalProperty('location', location);
defineGlobalProperty('navigator', navigator);
defineGlobalProperty('XMLHttpRequest', XMLHttpRequest);
defineGlobalProperty('asyncStorage', asyncStorage);
defineGlobalProperty('URLSearchParams', URLSearchParams);
defineGlobalProperty('URL', URL);
defineGlobalProperty('kraken', kraken);
defineGlobalProperty('__history__', history, false);

function defineGlobalProperty(key: string, value: any, isEnumerable: boolean = true) {
  Object.defineProperty(globalThis, key, {
    value: value,
    enumerable: isEnumerable,
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

class ErrorEvent extends Event {
  message?: string;
  lineno?: number;
  constructor(type: string, init?: ErrorEventInit) {
    super(type);

    if (init) {
      this.message = init.message;
      this.lineno = init.lineno;
    }
  }
}

// Global error handler used by JS Engine
// @ts-ignore
window.__global_onerror_handler__ = function (error) {
  if (window.onerror) {
    window.onerror(error.message, error.sourceURL, error.line, error.column, error);
  }

  // @ts-ignore
  const event = new ErrorEvent('error',{
    error: error,
    message: error.message,
    lineno: error.line
  });
  // @ts-ignore
  window.dispatchEvent(event);
};

// default unhandled project handler
// window.addEventListener('unhandledrejection', (event) => {
//   console.error('Unhandled Promise Rejection: ' + event.reason);
// });
