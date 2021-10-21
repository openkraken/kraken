import { URL } from './url';
import { kraken } from './kraken';

// @ts-ignore
const krakenLocation = window.__location__;
// Lazy parse url.
let _url: URL;
export function getUrl() : URL {
  return _url ? _url : (_url = new URL(krakenLocation.href));
}

const bindReload = krakenLocation.reload.bind(krakenLocation);
export const location = {
  get href() {
    return kraken.invokeModule('Location', 'getHref');
  },
  set href(url: string) {
    kraken.invokeModule('Navigation', 'goTo', url);
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
      kraken.invokeModule('Navigation', 'goTo', assignURL);
    };
  },
  get reload() {
    return bindReload;
  },
  get replace() {
    return (replaceURL: string) => {
      kraken.invokeModule('Navigation', 'goTo', replaceURL);
    };
  },
  get toString() {
    return () => location.href;
  },
};
