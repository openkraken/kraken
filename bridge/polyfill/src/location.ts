import { krakenWindow } from './bridge';
import { URL } from './url';
import { UnImplError } from './unimpl-error';

const krakenLocation = krakenWindow.location;
// Lazy parse url.
let _url: URL;
function getUrl() : URL {
  return _url ? _url : (_url = new URL(krakenLocation.href));
}

export const location = {
  get href() {
    return krakenLocation.href;
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
      throw new UnImplError('location.assign');
    };
  },
  get reload() {
    return krakenLocation.reload;
  },
  get replace() {
    return (replaceURL: string) => {
      throw new UnImplError('location.replace');
    };
  },
  get toString() {
    return () => location.href;
  },
};