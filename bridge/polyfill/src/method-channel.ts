import { kraken } from './kraken';

type MethodCallHandler = (method: string, args: any[]) => void;

let methodCallHandlers: MethodCallHandler[] = [];

// Like flutter platform channels
export const methodChannel = {
  setMethodCallHandler(handler: MethodCallHandler) {
    console.warn('kraken.methodChannel.setMethodCallHandler is a Deprecated API, use kraken.methodChannel.addMethodCallHandler instead.');
    methodChannel.addMethodCallHandler(handler);
  },
  addMethodCallHandler(handler: MethodCallHandler) {
    methodCallHandlers.push(handler);
  },
  removeMethodCallHandler(handler: MethodCallHandler) {
    let index = methodCallHandlers.indexOf(handler);
    if (index != -1) {
      methodCallHandlers.splice(index, 1); 
    }
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
