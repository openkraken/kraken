import { kraken } from './kraken';

type MethodCallHandler = (method: string, args: any[]) => void;

let methodCallHandlers: MethodCallHandler[] = [];

// Like flutter platform channels
export const methodChannel = {
  setMethodCallHandler(handler: MethodCallHandler) {
    methodCallHandlers.push(handler);
  },
  clearMethodCallHandler() {
    methodCallHandlers.length = 0;
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
    for (let handler of methodCallHandlers) {
      handler(method, args);
    }
  }
}
