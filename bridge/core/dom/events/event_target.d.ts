
// TODO: support options for addEventListener and removeEventListener
interface EventTarget {
  addEventListener(type: string, callback: JSEventListener | null): void;
  dispatchEvent(event: Event): boolean;
  removeEventListener(type: string, callback: JSEventListener | null): void;
  new(): EventTarget;
}
