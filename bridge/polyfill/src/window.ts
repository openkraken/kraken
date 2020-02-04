import { EventTarget } from 'event-target-shim';
import { KrakenLocation, Location } from './location';

export interface KrakenWindow {
  onload: () => void;
  devicePixelRatio: number;
  location: KrakenLocation;
}

declare var __kraken_window__: KrakenWindow;

export const originLocation = __kraken_window__.location;

class Window extends EventTarget {
  public location: Location;
  private _onload = () => {
    this.dispatchEvent({
      type: 'load',
    });
  };

  constructor() {
    super();
    this.location = new Location();
    __kraken_window__.onload = this._onload;
  }

  set onload(fn: any) {
    __kraken_window__.onload = fn;
  }

  get devicePixelRatio() {
    return __kraken_window__.devicePixelRatio;
  }
}

var window = new Window();

//@ts-ignore
// prevent user override buildin WebSocket class
Object.defineProperty(global, 'window', {
  enumerable: true,
  writable: false,
  value: window,
  configurable: false
});

Object.defineProperty(global, 'location', {
  enumerable: true,
  writable: false,
  value: window.location,
  configurable: false
});
