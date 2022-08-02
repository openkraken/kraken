/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

import { addWebfModuleListener, webfInvokeModule } from './bridge';
import { methodChannel, triggerMethodCallHandler } from './method-channel';
import { dispatchConnectivityChangeEvent } from "./connection";

function webfModuleListener(moduleName: string, event: Event, data: any) {
  switch (moduleName) {
    case 'Connection': {
      dispatchConnectivityChangeEvent(event);
      break;
    }
    case 'MethodChannel': {
      const method = data[0];
      const args = data[1];
      triggerMethodCallHandler(method, args);
      break;
    }
  }
}

addWebfModuleListener(webfModuleListener);

export const webf = {
  methodChannel,
  invokeModule: webfInvokeModule,
  addWebfModuleListener: addWebfModuleListener
};
