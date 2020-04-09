import {EventTarget} from './document/event-target';
import {krakenWindow, KrakenLocation} from './bridge';
import {NodeId} from "./document/node";


class Window extends EventTarget {
  private static buildInEvents = ['load', 'colorschemechange'];

  constructor() {
    super(NodeId.WINDOW, Window.buildInEvents);
  }

  public get colorScheme(): string {
    return krakenWindow.colorScheme;
  }

  public get devicePixelRatio() : number {
    return krakenWindow.devicePixelRatio;
  }

  public get location(): KrakenLocation {
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
