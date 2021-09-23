import 'es6-promise/dist/es6-promise.auto';
import './dom';
import { console } from './console';
import { fetch, Request, Response, Headers } from './fetch';
import { matchMedia } from './match-media';
import { location } from './location';
import { navigator } from './navigator';
import { XMLHttpRequest } from './xhr';
import { asyncStorage } from './async-storage';
import { URLSearchParams } from './url-search-params';
import { URL } from './url';
import { kraken } from './kraken';
import { ErrorEvent, PromiseRejectionEvent, PopStateEvent } from './events';

defineGlobalProperty('ErrorEvent', ErrorEvent);
defineGlobalProperty('PromiseRejectionEvent', PromiseRejectionEvent);
defineGlobalProperty('PopStateEvent', PopStateEvent);
defineGlobalProperty('console', console);
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
defineGlobalProperty('ErrorEvent', ErrorEvent);

function defineGlobalProperty(key: string, value: any, isEnumerable: boolean = true) {
  Object.defineProperty(globalThis, key, {
    value: value,
    enumerable: isEnumerable,
    writable: false,
    configurable: false
  });
}

// Unhandled global promise handler used by JS Engine.
// @ts-ignore
window.__global_unhandled_promise_handler__ = function (promise, reason) {
  // @ts-ignore
  const errorEvent = new ErrorEvent({
    error: reason,
    message: reason.message,
    lineno: reason.lineNumber,
    filename: reason.fileName,
    colno: 0
  });
  // @ts-ignore
  const rejectionEvent = new PromiseRejectionEvent({
    promise,
    reason
  });
  // @ts-ignore
  window.dispatchEvent(rejectionEvent);
  // @ts-ignore
  window.dispatchEvent(errorEvent);
};

// Global error handler used by JS Engine
// @ts-ignore
window.__global_onerror_handler__ = function (error) {
  try {
    // @ts-ignore
    const event = new ErrorEvent('error', {
      error: error,
      message: error.message,
      lineno: error.lineNumber,
      filename: error.fileName,
      colno: 0
    });
    // @ts-ignore
    window.dispatchEvent(event);
  } catch (e) {
    console.log(e);
  }
};

// default unhandled project handler
window.addEventListener('unhandledrejection', (event) => {
  console.error('Unhandled Promise Rejection: ' + event.reason);
});
