import {kraken} from "../kom/kraken";

type MethodCallHandler = (method: string, args: any[]) => void;

let methodCallHandlers: MethodCallHandler[] = [];

// Like flutter platform channels
export const methodChannel = {
  setMethodCallHandler(handler: MethodCallHandler) {
    methodCallHandlers.push(handler);
    kraken.invokeModule('MethodChannel', 'setMethodCallHandler');
  },
  invokeMethod(method: string, ...args: any[]): Promise<string> {
    return new Promise((resolve, reject) => {
      kraken.invokeModule('MethodChannel', 'invokeMethod', [method, args], (e, data) => {
        if (e) return reject(e);
        resolve(data);
      });
    });
  },
};

export function triggerMethodCallHandler(method: string, args: any) {
  if (methodCallHandlers.length > 0) {
    for (let i = 0; i < methodCallHandlers.length; i ++) {
      methodCallHandlers[i](method, args);
    }
  }
}
