import { krakenModuleListener } from './kraken';
import { positionWatcherMap, onConnectivityChangeListener } from './navigator';

krakenModuleListener(message => {
  let parsed = JSON.parse(message);
  const type = parsed[0];
  if (type === 'onConnectivityChanged') {
    if (onConnectivityChangeListener) {
      const event = parsed[1];
      onConnectivityChangeListener(event);
    }
  } else if (type === 'watchPosition') {
    const result = parsed[1];
    positionWatcherMap.forEach((value) => {
      if (result['coords'] != null) {
        value['success'](result);
      } else if (value['error'] != null) {
        value['error'](result);
      }
    });
  }
});
