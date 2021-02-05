// import { dispatchMQTTEvent } from './mqtt';
// import { dispatchPositionEvent } from './geolocation';
// import { triggerMethodCallHandler } from './method-channel';
// import { dispatchWebSocketEvent } from './websocket';

export function krakenModuleListener(moduleName: string, event: Event, extra: string) {
  console.log(moduleName);
  // switch (moduleName) {
  //   case 'connection': {
  //     break;
  //   }
  // }

  // if (type === 'onConnectivityChanged') {
  //   const eventInfo = parsed[1];
  //   const nativeEventAddress = eventInfo.nativeEvent;
  //   const eventType = eventInfo.type;
  //   // @ts-ignore
  //   const event = Event.__initWithNativeEvent__(eventType, nativeEventAddress);
  //   dispatchConnectivityChangeEvent(event);
  // } else if (type === 'watchPosition') {
  //   const event = parsed[1];
  //   dispatchPositionEvent(event);
  // } else if (type === 'MQTT') {
  //   const clientId = parsed[1];
  //   const eventInfo = parsed[2];
  //   const nativeEventAddress = eventInfo.nativeEvent;
  //   const eventType = eventInfo.type;
  //   // @ts-ignore
  //   const event = Event.__initWithNativeEvent__(eventType, nativeEventAddress);
  //   dispatchMQTTEvent(clientId, event);
  // } else if (type === 'MethodChannel') {
  //   const method = parsed[1];
  //   const args = parsed[2];
  //   triggerMethodCallHandler(method, args);
  // } else if (type === 'WebSocket') {
  //   const clientId = parsed[1];
  //   const eventInfo = parsed[2];
  //   const nativeEventAddress = eventInfo.nativeEvent;
  //   const eventType = eventInfo.type;
  //   // @ts-ignore
  //   const event = Event.__initWithNativeEvent__(eventType, nativeEventAddress);
  //   dispatchWebSocketEvent(clientId, event);
  // }
}
