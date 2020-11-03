import { krakenWindow, KrakenWindow } from '../bridge';
import { registerGlobalEventHandlers } from './global-event-handlers';
import { history } from './history';

// Window is not inherit node but EventTarget, so we assume window is a node.
const WINDOW = -2;

const windowBuiltInEvents = ['load', 'colorschemechange'];
const windowJsOnlyEvents = ['unhandledrejection', 'error'];

// window is global object, which is created by JSEngine,
// This is an extension which add more methods to global window object.
class WindowExtension extends EventTarget {
  constructor() {
    // @ts-ignore
    super(WINDOW, windowBuiltInEvents, windowJsOnlyEvents);
  }

  public get colorScheme(): string {
    return (krakenWindow as KrakenWindow).colorScheme;
  }

  public get devicePixelRatio() : number {
    return krakenWindow.devicePixelRatio;
  }

  public get window() {
    return this;
  }
}

if (process.env.ENABLE_JSA) {
  const windowExtension = new WindowExtension();
  Object.assign(window, windowExtension);

  let propertyEvents = {};
  windowBuiltInEvents.forEach(event => {
    let eventName = 'on' + event.toLowerCase();
    propertyEvents[eventName] = {
      get() {
        return windowExtension[eventName];
      },
      set(fn: EventListener) {
        windowExtension[eventName] = fn;
      }
    };
  });

  Object.defineProperties(window, {
    ...propertyEvents,
    history: {
      get() {
        return history;
      },
    },
    parent: {
      get() {
        return window;
      }
    },
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
    },
    __clearListeners__: {
      // @ts-ignore
      get() { return windowExtension.__clearListeners__.bind(windowExtension); }
    },
    scroll: {
      get() { return document.body.scroll.bind(document.body); }
    },
    scrollBy: {
      get() { return document.body.scrollBy.bind(document.body); }
    },
    scrollTo: {
      get() { return document.body.scrollTo.bind(document.body); }
    },
    scrollX: {
      get() { return document.body.scrollLeft; }
    },
    scrollY: {
      get() { return document.body.scrollTop; }
    }
  });

  registerGlobalEventHandlers(window);
}
