/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

import { webfInvokeModule } from './bridge';

type MethodCallHandler = (method: string, args: any[]) => void;

let methodCallHandlers: MethodCallHandler[] = [];

// Like flutter platform channels
export const methodChannel = {
  setMethodCallHandler(handler: MethodCallHandler) {
    console.warn('webf.methodChannel.setMethodCallHandler is a Deprecated API, use webf.methodChannel.addMethodCallHandler instead.');
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
      webfInvokeModule('MethodChannel', 'invokeMethod', [method, args], (e, data) => {
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
