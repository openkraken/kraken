import { dispatchConnectivityChangeEvent } from './connection';
import { dispatchMQTTEvent } from './mqtt';
import { dispatchPositionEvent } from './geolocation';
import { triggerMethodCallHandler } from './method-channel';
import { dispatchWebSocketEvent } from './websocket';

export function krakenModuleListener(message: any) {
  let parsed = JSON.parse(message);
  const type = parsed[0];
  if (type === 'onConnectivityChanged') {
    const event = parsed[1];
    dispatchConnectivityChangeEvent(event);
  } else if (type === 'watchPosition') {
    const event = parsed[1];
    dispatchPositionEvent(event);
  } else if (type === 'MQTT') {
    const clientId = parsed[1];
    const event = parsed[2];
    dispatchMQTTEvent(clientId, event);
  } else if (type === 'MethodChannel') {
    const method = parsed[1];
    const args = parsed[2];
    triggerMethodCallHandler(method, args);
  } else if (type === 'WebSocket') {
    const clientId = parsed[1];
    const event = parsed[2];
    dispatchWebSocketEvent(clientId, event);
  }
}
