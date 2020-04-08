import { krakenInvokeModule } from './bridge';
import { EventTarget} from 'event-target-shim';

// https://www.w3.org/TR/hr-time-2/#the-performance-interface
class Performance extends EventTarget {
  private _timeOrigin: number;

  constructor() {
    super();
    this._timeOrigin = this.now();
  }

  public get timeOrigin() : number {
    return this._timeOrigin;
  }

  public now() : number {
    const timeStamp = krakenInvokeModule('["Performance","now"]');
    return parseFloat(timeStamp);
  }

  public toJSON() {
    return {
      timeOrigin: this._timeOrigin,
    };
  }
}

Object.defineProperty(global, 'performance', {
  enumerable: true,
  writable: false,
  value: new Performance(),
  configurable: false
});
