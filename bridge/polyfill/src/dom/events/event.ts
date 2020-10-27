import { EventTarget } from './event-target';

export class Event {
  type: string;
  cancelable: boolean;
  bubbles: boolean;
  currentTarget: EventTarget | null;
  target: EventTarget | null;

  [key: string]: any;

  constructor(type: string, eventInit?: EventInit) {
    this.type = type;
    this.bubbles = false;
    this.cancelable = false;

    if (eventInit) {
      Object.assign(this, eventInit);
    }

    this.target = null;
    this.currentTarget = null;

    this._initializedFlag = true;
    this._stopPropagationFlag = false;
    this._stopImmediatePropagationFlag = false;
    this._inPassiveListenerFlag = false;
    this._canceledFlag = false;
    this._dispatchFlag = false;
  }

  // https://dom.spec.whatwg.org/#set-the-canceled-flag
  _setTheCanceledFlag() {
    if (this.cancelable && !this._inPassiveListenerFlag) {
      this._canceledFlag = true;
    }
  }

  get srcElement() {
    return this.target;
  }

  get returnValue() {
    return !this._canceledFlag;
  }

  get defaultPrevented() {
    return this._canceledFlag;
  }

  stopPropagation() {
    this._stopPropagationFlag = true;
  }

  get cancelBubble() {
    return this._stopPropagationFlag;
  }

  set cancelBubble(v) {
    if (v) {
      this._stopPropagationFlag = true;
    }
  }

  stopImmediatePropagation() {
    this._stopPropagationFlag = true;
    this._stopImmediatePropagationFlag = true;
  }

  preventDefault() {
    this._setTheCanceledFlag();
  }

  _initialize(type: string, bubbles: boolean = false, cancelable: boolean = false) {
    this.type = type;
    this._initializedFlag = true;

    this._stopPropagationFlag = false;
    this._stopImmediatePropagationFlag = false;
    this._canceledFlag = false;

    this.isTrusted = false;
    this.target = null;
    this.bubbles = bubbles;
    this.cancelable = cancelable;
  }

  initEvent(type: string, bubbles: boolean = false, cancelable: boolean = false) {
    if (this._dispatchFlag) {
      return;
    }

    this._initialize(type, bubbles, cancelable);
  }
}
