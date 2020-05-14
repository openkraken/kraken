import { addEvent } from './ui-manager';

export const BODY = -1;
// Window is not inherit node but EventTarget, so we assume window is a node.
export const WINDOW = -2;

type EventHandler = EventListener;

export class EventTarget {
  public targetId: number;
  __eventHandlers: Map<string, Array<EventHandler>> = new Map();
  __propertyEventHandler: Map<string, EventHandler> = new Map();

  constructor(targetId?: number, builtInEvents: Array<string> = []) {
    if (targetId) {
      this.targetId = targetId;
    }
    builtInEvents.forEach(event => {
      let eventName = 'on' + event.toLowerCase();
      Object.defineProperty(this, eventName, {
        get() {
          return this.__propertyEventHandler.get(event);
        },
        set(fn: EventHandler) {
          const preHandler = this.__propertyEventHandler[event];
          this.removeEventListener(event, preHandler);
          this.__propertyEventHandler.set(event, fn);
          if (typeof fn === 'function') {
            this.addEventListener(event, fn);
          }
        }
      });
    });
  }

  // internal functions used by integration test
  public __clearListeners__() {
    if (process.env.NODE_ENV !== 'production') {
      this.__eventHandlers.clear();
      this.__propertyEventHandler.clear();
    }
  }

  public addEventListener(eventName: string, handler: EventHandler) {
    if (typeof handler !== 'function') {
      return;
    }
    if (!this.__eventHandlers.has(eventName) || this.targetId === BODY) {
      this.__eventHandlers.set(eventName, []);

      // this is an bargain optimize for addEventListener which send `addEvent` message to kraken Dart side only once and no one can stop element to
      // trigger event from dart side. this can led to significant performance improvement when using Front-End frameworks such as Rax, or cause some
      /// overhead performance issue when some event trigger more frequently.
      if (this.targetId) {
        addEvent(this.targetId, eventName);
      }
    }
    this.__eventHandlers.get(eventName)!.push(handler);
  }

  // Do not really emit remove event, due to performance consideration.
  public removeEventListener(eventName: string, handler: EventHandler) {
    if (typeof handler !== 'function' || !this.__eventHandlers.has(eventName)) {
      return;
    }
    let newHandler = this.__eventHandlers.get(eventName)!.filter(fn => fn != handler);
    this.__eventHandlers.set(eventName, newHandler);
  }

  public dispatchEvent(event: Event) {
    if (!this.__eventHandlers.has(event.type)) {
      return;
    }
    event.currentTarget = event.target = this;
    let stack = this.__eventHandlers.get(event.type)!.slice();

    for (let i = 0; i < stack.length; i++) {
      stack[i].call(this, event);
    }

    return !event.defaultPrevented;
  }
}

export class Event {
  type: string;
  cancelable: boolean;
  currentTarget: EventTarget;
  target: EventTarget;
  defaultPrevented: boolean;

  [key: string]: any;

  constructor(type: string) {
    this.type = type;
  }
}

export class PromiseRejectionEvent extends Event {
  promise: Promise<any>;
  reason?: any;
  constructor(eventInit?: PromiseRejectionEventInit) {
    super('unhandledrejection');

    if (eventInit) {
      this.promise = eventInit.promise;
      this.reason = eventInit.reason;
    }
  }
}

export class ErrorEvent extends Event {
  colno: number;
  error: any;
  filename: string;
  lineno: number;
  message: string;

  constructor(init?: ErrorEventInit) {
    super('error');
    if (init) {
      Object.assign(this, init);
    }
  }
}
