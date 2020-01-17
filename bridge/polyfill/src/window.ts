import {EventTarget} from 'event-target-shim';

interface KrakenWindow {
  connect: (
    onload: () => void,
    initDevicePixelRatio: (dp: number) => void
  ) => void;
}

declare var __kraken_window__: KrakenWindow;

class Window extends EventTarget {

  public devicePixelRatio:number;
  private _onload = () => {
    this.dispatchEvent({
      type: 'load',
    });
  };

  private _initDevicePixelRatio = (dp: number) => {
    this.devicePixelRatio = dp;
  }

  constructor() {
    super();
    this.devicePixelRatio = 1;
    __kraken_window__.connect(this._onload, this._initDevicePixelRatio);
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
