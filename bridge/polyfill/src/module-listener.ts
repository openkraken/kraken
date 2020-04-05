import { krakenModuleListener } from './types';
import { positionWatcherMap, onConnectivityChangeListener } from './navigator';
import { dispatchMQTT } from './mqtt';
import {dispatchMethodChannel} from "./method-channel";

krakenModuleListener(message => {
  let parsed = JSON.parse(message);
  const type = parsed[0];
  if (type === 'onConnectivityChanged') {
    if (onConnectivityChangeListener) {
      const event = parsed[1];
      onConnectivityChangeListener(event);
    }
  } else if (type === 'watchPosition') {
    const event = parsed[1];
    positionWatcherMap.forEach((value) => {
      if (event.coords != null) {
        value.success(event);
      } else if (value.error != null) {
        value.error(event);
      }
    });
  } else if (type === 'MQTT') {
    const clientId = parsed[1];
    const event = parsed[2];
    dispatchMQTT(clientId, event);
  } else if (type === 'PlatformChannel') {
    const method = parsed[1];
    const args = parsed[2];
    dispatchMethodChannel(method, args);
  }
});
