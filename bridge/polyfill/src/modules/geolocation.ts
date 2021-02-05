import {kraken} from "../kom/kraken";

const positionWatcherMap = new Map<string, any>();

export function dispatchPositionEvent(event: any) {
  positionWatcherMap.forEach((watcher) => {
    if (event.coords != null) {
      watcher.success(event);
    } else if (watcher.error != null) {
      watcher.error(event);
    }
  });
}

export default {
  getCurrentPosition(success: (data: any) => void, error?: (error: any) => void, options?: any) {
    let optionsStr = '';
    if (options != null) {
      optionsStr = JSON.stringify(options);
    }
    kraken.invokeModule('Geolocation', 'getCurrentPosition', optionsStr, (e, result) => {
      if (e && error) return error(e);
      if (result['coords'] != null) {
        success(result);
      } else if (error != null) {
        error(result);
      }
    });
  },
  watchPosition(success: (data: any) => void, error?: (error: any) => void, options?: any) {
    let optionsStr = '';
    if (options != null) {
      optionsStr = JSON.stringify(options);
    }
    const watchId = kraken.invokeModule('Geolocation', 'watchPosition', optionsStr);
    positionWatcherMap.set(watchId, {success: success, error: error});
    return parseInt(watchId);
  },
  clearWatch(id: number) {
    positionWatcherMap.delete(id.toString());
    if (positionWatcherMap.size === 0) {
      kraken.invokeModule('Geolocation', 'clearWatch');
    }
  }
}
