import {addEvent} from "./ui-manager";
import {NodeId} from "./node";

type EventHandler = EventListener;

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

export class EventTarget {
  public nodeId: number;
  __eventHandlers: Map<string, Array<EventHandler>> = new Map();
  __propertyEventHandler: Map<string, EventHandler> = new Map();

  constructor(nodeId?: number, buildInEvents: Array<string> = []) {
    if (nodeId) {
      this.nodeId = nodeId;
    }
    buildInEvents.forEach(event => {
      let eventName = 'on' + event.toLowerCase();
      Object.defineProperty(this, eventName, {
        get() {
          return this.__propertyEventHandler[event];
        },
        set(fn: EventHandler) {
          this.__propertyEventHandler[event] = fn;
          this.addEventListener(event, fn);
        }
      });
    });
  }

  public addEventListener(eventName: string, handler: EventHandler) {
    if (!this.__eventHandlers.has(eventName) || this.nodeId === NodeId.BODY) {
      this.__eventHandlers.set(eventName, []);

      // this is an bargain optimize for addEventListener which send `addEvent` message to kraken Dart side only once and no one can stop element to
      // trigger event from dart side. this can led to significant performance improvement when using Front-End frameworks such as Rax, or cause some
      /// overhead performance issue when some event trigger more frequently.
      if (this.nodeId) {
        addEvent(this.nodeId, eventName);
      }
    }
    this.__eventHandlers.get(eventName)!.push(handler);
  }

  // Do not really emit remove event, due to performance consideration.
  public removeEventListener(eventName: string, handler: EventHandler) {
    if (!this.__eventHandlers.has(eventName)) {
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