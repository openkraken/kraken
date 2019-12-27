import {EventTarget} from 'event-target-shim';

interface KrakenWindow {
  bindOnload: (
    onload: () => void
  ) => void;
}

declare var __kraken_window__: KrakenWindow;

class Window extends EventTarget {

  private _onload = () => {
    this.dispatchEvent({
      type: 'load',
    });
  };

  constructor() {
    super();
    __kraken_window__.bindOnload(this._onload);
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
