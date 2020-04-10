import { EventTarget } from 'event-target-shim';
import { krakenWindow, KrakenLocation } from './bridge';
import { addEvent } from "./document/ui-manager";
import { NodeId } from "./document/node";

class Window extends EventTarget {
  private events: {
    [eventName: string]: any;
  } = {};

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

// window is global object, which is created by JSEngine, assign some
// window API from polyfill.
Object.assign(window, new Window());
