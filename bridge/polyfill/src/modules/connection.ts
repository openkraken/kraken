import { kraken } from '../kom/kraken';
let connectivityChangeListener: (data: Object) => any;

export function dispatchConnectivityChangeEvent(event: any) {
  if (connectivityChangeListener) {
    connectivityChangeListener(event);
  }
}

export default {
  getConnectivity() {
    return new Promise((resolve) => {
      kraken.invokeModule('Connection', 'getConnectivity', '', (json) => {
        resolve(json);
      });
    });
  },
  set onchange(listener: (data: Object) => any) {
    if (typeof listener === 'function') {
      connectivityChangeListener = listener;
      // TODO: should remove old listener when onchange reset with a null listener
      kraken.invokeModule('Connection', 'onConnectivityChanged');
    }
  }
}
