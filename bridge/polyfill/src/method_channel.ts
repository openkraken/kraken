import {EventTarget} from 'event-target-shim';
import {krakenInvokeModule} from "./types";

export function dispatchMethodChannel(method: string, args: any) {
  if (methodChannel) {
    methodChannel._triggerHandler(method, args);
  }
}

type MethodHandler = (method: string, args: any[]) => Promise<String>;
export class MethodChannel extends EventTarget {
  private _handler: MethodHandler = async (method: string, args: any) => '';
  constructor() {
    super();
  }

  public _triggerHandler(method: string, args: any) {
    this._handler(method, args);
  }

  setMethodHandler(handler: MethodHandler) {
    this._handler = handler;
  }

  invokeMethod(method: string, ...args: any[]): Promise<String> {
    return new Promise((resolve, reject) => {
      krakenInvokeModule(JSON.stringify([
        'PlatformChannel',
        'method',
        method,
        args
      ]), (result) => {
        if (result.indexOf('Dart Error') >= 0) {
          reject(new Error(result));
        } else {
          resolve(result);
        }
      })
    });
  }
}

export const methodChannel = new MethodChannel();