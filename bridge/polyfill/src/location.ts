import {krakenInvokeModule, krakenWindow} from './bridge';
import { URL } from './url';

const krakenLocation = krakenWindow.location;
// Lazy parse url.
let _url: URL;
export function getUrl() : URL {
  return _url ? _url : (_url = new URL(krakenLocation.href));
}

export const location = {
  get href() {
    return getUrl().href;
  },
  set href(url: string) {
    krakenInvokeModule(JSON.stringify(['KrakenNavigation', url]));
  },
  get origin() {
    return getUrl().origin;
  },
  get protocol() {
    return getUrl().protocol;
  },
  get host() {
    return getUrl().host;
  },
  get hostname() {
    return getUrl().hostname;
  },
  get port() {
    return getUrl().port;
  },
  get pathname() {
    return getUrl().pathname;
  },
  get search() {
    return getUrl().search;
  },
  get hash() {
    return getUrl().hash;
  },

  get assign() {
    return (assignURL: string) => {
      krakenInvokeModule(JSON.stringify(['KrakenNavigation', assignURL]));
    };
  },
  get reload() {
    return krakenLocation.reload;
  },
  get replace() {
    return (replaceURL: string) => {
      krakenInvokeModule(JSON.stringify(['KrakenNavigation', replaceURL]))
    };
  },
  get toString() {
    return () => location.href;
  },
};
