// IDL definitions for GlobalEventHandlers
// https://html.spec.whatwg.org/multipage/webappapis.html#idl-definitions

const EVENT_PREFIX = 'on';
const EVENT_ERROR = 'error';
let _onErrorEventListener: EventListener | null;
let _onErrorEventHandler: OnErrorEventHandler;
export const GlobalEventHandlers = {
  get onerror() : OnErrorEventHandler{
    return _onErrorEventHandler ?? null;
  },
  set onerror(errorEventHandler: OnErrorEventHandler) {
    _onErrorEventHandler = errorEventHandler;

    if (errorEventHandler) {
      _onErrorEventListener = (event: ErrorEvent) => {
        const error: Error = event.error;
        errorEventHandler(event, error['sourceURL'] || location.href, error['line'] || 0, error['column'] || 0, error);
      };
      addEventListener(EVENT_ERROR, _onErrorEventListener);
    } else {
      if (_onErrorEventListener) {
        removeEventListener(EVENT_ERROR, _onErrorEventListener);
        _onErrorEventListener = null;
      }
    }
  },
};

export const globalEvents = [
  EVENT_PREFIX + EVENT_ERROR,
];

export function registerGlobalEventHandlers(window: Window) {
  // Register global event handlers for window.
  globalEvents.forEach((key: string) => {
    const propertyDecorator = Object.getOwnPropertyDescriptor(GlobalEventHandlers, key);
    if (propertyDecorator) {
      Object.defineProperty(window, key, propertyDecorator as PropertyDecorator);
    }
  });
}
