interface EventTarget {
  addEventListener(type: string, callback: EventListener | null): void;
  dispatchEvent(event: Event): boolean;
  removeEventListener(type: string, callback: EventListener | null): void;
  new(): EventTarget;
}
