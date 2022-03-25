interface EventTarget {
  addEventListener(type: string, callback: EventListenerOrEventListenerObject | null): void;
  dispatchEvent(event: Event): boolean;
  removeEventListener(type: string, callback: EventListenerOrEventListenerObject | null): void;
  new(): EventTarget;
}
