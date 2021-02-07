import {dispatchConnectivityChangeEvent} from "./connection";
import {dispatchPositionEvent} from "./geolocation";
import {dispatchMQTTEvent} from "./mqtt";
import {triggerMethodCallHandler} from "./method-channel";
import {dispatchWebSocketEvent} from "./websocket";

export function krakenModuleListener(moduleName: string, event: Event, data: any) {
  switch (moduleName) {
    case 'Connection': {
      dispatchConnectivityChangeEvent(event);
      break;
    }
    case 'Geolocation': {
      dispatchPositionEvent(data);
      break;
    }
    case 'MQTT': {
      dispatchMQTTEvent(data, event)
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
