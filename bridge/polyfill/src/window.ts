import { EventTarget } from 'event-target-shim';
import { krakenWindow, KrakenLocation } from './kraken';

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

  constructor() {
    super();
    bindLegacyListeners(this, ['load', 'colorschemechange']);

    // Bridge native event callback to EventTarget.
    krakenWindow.onLoad = () => {
      this.dispatchEvent({
        type: 'load',
        target: this,
        currentTarget: this,
        bubbles: false,
        cancelable: false,
      });
    };
    krakenWindow.onColorSchemeChange = () => {
      this.dispatchEvent({
        type: 'colorschemechange',
        target: this,
        currentTarget: this,
        bubbles: false,
        cancelable: false,
      });
    };
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
