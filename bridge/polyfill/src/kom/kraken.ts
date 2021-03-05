import { addKrakenModuleListener, krakenInvokeModule, privateKraken } from '../bridge';
import {methodChannel, triggerMethodCallHandler} from '../modules/method-channel';
import {dispatchConnectivityChangeEvent} from "../modules/connection";
import {dispatchWebSocketEvent} from "../modules/websocket";

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
    case 'WebSocket': {
      dispatchWebSocketEvent(data, event as ErrorEvent);
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
