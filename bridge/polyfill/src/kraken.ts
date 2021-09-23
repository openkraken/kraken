import { addKrakenModuleListener, krakenInvokeModule, privateKraken } from './bridge';
import { methodChannel, triggerMethodCallHandler } from './method-channel';
import { dispatchConnectivityChangeEvent } from "./connection";

function krakenModuleListener(moduleName: string, event: Event, data: any) {
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

addKrakenModuleListener(krakenModuleListener);

export const kraken = {
  ...privateKraken,
  methodChannel,
  invokeModule: krakenInvokeModule,
  addKrakenModuleListener: addKrakenModuleListener
};
