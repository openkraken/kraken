import {krakenInvokeModule} from "./bridge";

type MethodCallHandler = (method: string, args: any[]) => void;

let methodCallHandler: MethodCallHandler;

// Like flutter platform channels
export const methodChannel = {
  setMethodCallHandler(handler: MethodCallHandler) {
    methodCallHandler = handler;
    krakenInvokeModule('["MethodChannel","setMethodCallHandler"]');
  },
  invokeMethod(method: string, ...args: any[]): Promise<string> {
    return new Promise((resolve, reject) => {
      krakenInvokeModule(JSON.stringify([
        'MethodChannel',
        'invokeMethod',
        [method, args]
      ]), (result) => {
        if (result.indexOf('Error:') === 0) {
          reject(new Error(result));
        } else {
          resolve(result);
        }
      })
    });
  },
};

export function dispatchMethodCallHandler(method: string, args: any) {
  if (methodCallHandler) {
    methodCallHandler(method, args);
  }
}