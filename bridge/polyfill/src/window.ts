import { EventTarget } from './document/event-target';
import { krakenWindow, KrakenLocation } from './bridge';
import { WINDOW } from "./document/event-target";

const windowBuildInEvents = ['load', 'colorschemechange'];

// window is global object, which is created by JSEngine,
// This is an extension which add more methods to global window object.
class WindowExtension extends EventTarget {
  constructor() {
    super(WINDOW, windowBuildInEvents);
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

  public get parent() {
    return this;
  }
}

export const windowExtension = new WindowExtension();
Object.defineProperties(window, {
  addEventListener: {
    get() {
      return windowExtension.addEventListener.bind(windowExtension);
    }
  },
  removeEventListener: {
    get() {
      return windowExtension.removeEventListener.bind(windowExtension);
    }
  },
  dispatchEvent: {
    get() {
      return windowExtension.dispatchEvent.bind(windowExtension);
    }
  }
});
