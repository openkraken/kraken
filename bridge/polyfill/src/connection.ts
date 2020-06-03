import { krakenInvokeModule } from './bridge';

let connectivityChangeListener: (data: Object) => any;

export function dispatchConnectivityChangeEvent(event: any) {
  if (connectivityChangeListener) {
    connectivityChangeListener(event);
  }
}

export default {
  getConnectivity() {
    return new Promise((resolve) => {
      krakenInvokeModule('["Connection","getConnectivity"]', (json) => {
        resolve(JSON.parse(json));
      });
    });
  },
  set onchange(listener: (data: Object) => any) {
    if (typeof listener === 'function') {
      connectivityChangeListener = listener;
      // TODO: should remove old listener when onchange reset with a null listener
      krakenInvokeModule('["Connection","onConnectivityChanged"]');
    }
  }
}
