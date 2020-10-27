import { Event } from './event';

export class CustomEvent extends Event {
  private _detail: any;

  constructor(type: string, eventInit?: CustomEventInit) {
    super(type);
    if (eventInit) {
      this._detail = eventInit.detail;
    }
  }

  get detail(): any {
    return this._detail;
  }

  initCustomEvent(type: string, bubbles: boolean = false, cancelable: boolean = false, detail: any = null) {
    if (this._dispatchFlag) {
      return;
    }

    this.initEvent(type, bubbles, cancelable);
    if (detail) {
      this._detail = detail;
    }
  }
}
