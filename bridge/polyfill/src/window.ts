import { EventTarget } from 'event-target-shim';
import { krakenWindow, KrakenLocation } from './bridge';
import { addEvent } from "./document/ui-manager";
import { NodeId } from "./document/node";


class Window extends EventTarget {
  private events: {
    [eventName: string]: any;
  } = {};

  constructor() {
    super();
  }

  set onload(fn: EventListener) {
    this.addEventListener('load', fn);
  }
  get onload() {
    return this.events['onload'];
  }
  set oncolorschemachange(fn: EventListener) {
    this.addEventListener('colorschemechange', fn);
  }
  get oncolorschemechange() {
    return this.events['colorschemechange'];
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
