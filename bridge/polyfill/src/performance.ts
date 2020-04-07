import {krakenInvokeModule} from "./bridge";

const performance = {
  now() {
    const timeStamp = krakenInvokeModule('["Performance","now"]');
    return parseFloat(timeStamp);
  }
};

Object.defineProperty(global, 'performance', {
  enumerable: true,
  writable: false,
  value: performance,
  configurable: false
});
