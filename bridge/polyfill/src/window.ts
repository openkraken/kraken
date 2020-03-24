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
    krakenWindow.onLoad = this.dispatchEvent;
    krakenWindow.onColorSchemeChange = this.dispatchEvent;
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
}


const window = new Window();

Object.defineProperty(global, 'window', {
  enumerable: true,
  writable: false,
  configurable: false,
  value: window,
});
