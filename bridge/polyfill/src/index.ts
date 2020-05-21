import { console } from './console';
import { document } from './document';
import { PromiseRejectionEvent, ErrorEvent } from './document/event-target';
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
import { traverseNode } from "./document/node";

Object.assign(window, windowExtension);

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

// Unhandled global promise handler used by JS Engine.
// @ts-ignore
window.__global_unhandled_promise_handler__ = function(promise, reason) {
  const errorEvent = new ErrorEvent({
    message: reason.message,
    error: reason
  });
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
window.__global_onerror_handler__ = function(error) {
  const event = new ErrorEvent({
    error: error,
    message: error.message,
    lineno: error.line
  });
  // @ts-ignore
  window.dispatchEvent(event);
};

// default unhandled project handler
window.addEventListener('unhandledrejection', (event) => {
  console.error('Unhandled Promise Rejection: ' + event.reason);
});

if (process.env.NODE_ENV !== 'production') {
  function clearAllEventsListeners() {
    // @ts-ignore
    window.__clearListeners__();
    // @ts-ignore
    traverseNode(document.body, (node) => {
      node.__clearListeners__();
    });
  }

  function clearAllNodes() {
    while (document.body.firstChild) {
      document.body.firstChild.remove();
    }
  }

  // @ts-ignore
  window.clearAllEventsListeners = clearAllEventsListeners;
  // @ts-ignore
  window.clearAllNodes = clearAllNodes;
}
