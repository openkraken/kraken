import { EventTarget } from 'event-target-shim';
import { krakenWindow, KrakenLocation } from './kraken';
import {NodeId} from "./document/node";
import {addEvent} from "./document/UIManager";

function bindLegacyListeners(eventTarget: EventTarget, events: string[]) {
  events.forEach((event: string) => {
    Object.defineProperty(eventTarget, 'on' + event, {
      enumerable: true,
      configurable: false,
      set(fn: any) {
        if (this['_on' + event]) this.removeEventListener(event, this['_on' + event]);
        this['_on' + event] = fn;
        this.addEventListener(event, fn);
      },
      get() {
        return this['_on' + event];
      },
    });
  });
}


class Window extends EventTarget {
  private events: {
    [eventName: string]: any;
  } = {};

  constructor() {
    super();
    bindLegacyListeners(this, ['load', 'colorschemechange']);
  }

  addEventListener(eventName: string, eventListener: EventListener) {
    super.addEventListener(eventName, eventListener);
    if (!this.events.hasOwnProperty(eventName)) {
      addEvent(NodeId.WINDOW, eventName);
      this.events[eventName] = eventListener;
    }
  }

  public get colorScheme() : string {
    return krakenWindow.colorScheme;
  }


  public get devicePixelRatio() : number {
    return krakenWindow.devicePixelRatio;
  }

  public get location() : KrakenLocation {
    return krakenWindow.location;
  }

  public get window() {
    return this;
  }
}

export const window = new Window();

Object.defineProperty(global, 'window', {
  enumerable: true,
  writable: false,
  configurable: false,
  value: window,
});
