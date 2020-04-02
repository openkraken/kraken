import {EventTarget} from 'event-target-shim';
import {krakenInvokeModule} from "./types";

export async function dispatchMethodChannel(method: string, args: any): Promise<string|undefined> {
  if (methodChannel) {
    return await methodChannel._triggerHandler(method, args);
  }
  return;
}

type MethodHandler = (method: string, args: any[]) => Promise<string>;
export class MethodChannel extends EventTarget {
  private _handler: MethodHandler = async (method: string, args: any) => '';
  constructor() {
    super();
  }

  public async _triggerHandler(method: string, args: any) {
    try {
      return await this._handler(method, args);
    } catch (e) {
      console.error(e);
      return undefined;
    }
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