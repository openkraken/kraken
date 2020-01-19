import {EventTarget} from 'event-target-shim';

interface KrakenWindow {
  onload: () => void;
  devicePixelRatio: number;
  location: KrakenLocation;
}

interface KrakenLocation {
  reload: () => void;
}

declare var __kraken_window__: KrakenWindow;

class Location {
  constructor() {}
  reload() {
    __kraken_window__.location.reload();
  }
}

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
