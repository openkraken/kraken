import { addKrakenUIListener } from './bridge';
import { krakenUIListener } from './ui-listener';
import { traverseNode } from "./node";
import { document } from "./document";
import { ErrorEvent } from "./events/error-event";
import { PromiseRejectionEvent } from "./events/promise-rejection-event";
import { ImageElement } from "./elements/img";
import { CustomEvent } from "./events/custom-event";
import { requestAnimationFrame } from "./animation-frame";
import { EventTarget } from './events/event-target';
import { Event } from './events/event';

addKrakenUIListener(krakenUIListener);

function defineGlobalProperty(key: string, value: any) {
  Object.defineProperty(globalThis, key, {
    value: value,
    enumerable: true,
    writable: false,
    configurable: false
  });
}

defineGlobalProperty('Image', ImageElement);
defineGlobalProperty('CustomEvent', CustomEvent);
defineGlobalProperty('requestAnimationFrame', requestAnimationFrame);
defineGlobalProperty('EventTarget', EventTarget);
defineGlobalProperty('Event', Event);
defineGlobalProperty('ErrorEvent', ErrorEvent);
defineGlobalProperty('PromiseRejectionEvent', PromiseRejectionEvent);
defineGlobalProperty('document', document);


if (process.env.NODE_ENV !== 'production') {
  // @ts-ignore
  function clearAllEventsListeners() {
    // @ts-ignore
    window.__clearListeners__();
    // @ts-ignore
    traverseNode(document.body, (node) => {
      node.__clearListeners__();
    });
  }

  // @ts-ignore
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
