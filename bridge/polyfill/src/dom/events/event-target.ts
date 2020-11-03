import { addEvent } from '../ui-manager';
import { Node } from '../node';
import { Event, EventType, getEventTypeOfName } from './event';

export const BODY = -1;
// Window is not inherit node but EventTarget, so we assume window is a node.
export const WINDOW = -2;

type EventHandler = EventListener;

export const eventTargetMap = {};

export class EventTarget {
  public targetId: number;
  // built-in events which no need to notify dart side.
  private _jsOnlyEvents: Array<string>;
  _eventHandlers: Map<EventType, Array<EventHandler>> = new Map();
  _propertyEventHandler: Map<string, EventHandler> = new Map();

  constructor(targetId?: number, builtInEvents: Array<string> = [], jsOnlyEvents: Array<string> = []) {
    if (targetId) {
      this.targetId = targetId;
      eventTargetMap[targetId] = this;
    }

    this._jsOnlyEvents = jsOnlyEvents;
    builtInEvents.forEach(event => {
      let eventName = 'on' + event.toLowerCase();
      Object.defineProperty(this, eventName, {
        get() {
          return this._propertyEventHandler.get(event);
        },
        set(fn: EventHandler) {
          const preHandler = this._propertyEventHandler[event];
          this.removeEventListener(event, preHandler);
          this._propertyEventHandler.set(event, fn);
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
      this._eventHandlers.clear();
      this._propertyEventHandler.clear();
    }
  }

  public addEventListener(eventName: string, handler: EventHandler) {
    if (typeof handler !== 'function') {
      return;
    }
    let eventType = getEventTypeOfName(eventName);
    if (!this._eventHandlers.has(eventType) || this.targetId === BODY) {
      this._eventHandlers.set(eventType, []);

      // this is an bargain optimize for addEventListener which send `addEvent` message to kraken Dart side only once and no one can stop element to
      // trigger event from dart side. this can led to significant performance improvement when using Front-End frameworks such as Rax, or cause some
      /// overhead performance issue when some event trigger more frequently.
      if (this.targetId && !this._jsOnlyEvents.includes(eventName)) {
        addEvent(this.targetId, eventType);
      }
    }
    this._eventHandlers.get(eventType)!.push(handler);
  }

  // Do not really emit remove event, due to performance consideration.
  public removeEventListener(eventName: string, handler: EventHandler) {
    let eventType = getEventTypeOfName(eventName);
    if (typeof handler !== 'function' || !this._eventHandlers.has(eventType)) {
      return;
    }
    let newHandler = this._eventHandlers.get(eventType)!.filter(fn => fn != handler);
    this._eventHandlers.set(eventType, newHandler);
  }

  public dispatchEvent(event: Event) {
    if (!this._eventHandlers.has(event.type)) {
      return;
    }
    event.currentTarget = event.target = this;

    // event has been dispatched, then do not dispatch
    event._dispatchFlag = true;
    let cancelled = true;

    while (event.currentTarget !== null) {
      cancelled = this._dispatchEvent(event);
      if (event.bubbles || cancelled) break;
      if (event.currentTarget) {
        let node = event.currentTarget as Node;
        event.currentTarget = node.parentNode as EventTarget;
      }
    }

    event._dispatchFlag = false;
    return !event.defaultPrevented;
  }

  private _dispatchEvent(event: Event) {
    let stack = this._eventHandlers.get(event.type)!.slice();

    for (let i = 0; i < stack.length; i++) {
      stack[i].call(this, event);
    }

    // do not dispatch event when event has been canceled
    return !event._canceledFlag;
  }
}
