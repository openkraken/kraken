import { krakenInvokeModule } from './bridge';

// https://www.w3.org/TR/hr-time-2/#the-performance-interface
// @NOTE: Not extends EventTarget due to over design.
class Performance {
  public get timeOrigin() : number {
    const timeStamp = krakenInvokeModule('["Performance","getTimeOrigin"]');
    return parseFloat(timeStamp);
  }

  public now() : number {
    const timeStamp = krakenInvokeModule('["Performance","now"]');
    return parseFloat(timeStamp);
  }

  public toJSON() {
    return {
      timeOrigin: this.timeOrigin,
    };
  }
}

Object.defineProperty(global, 'performance', {
  enumerable: true,
  writable: false,
  value: new Performance(),
  configurable: false
});
