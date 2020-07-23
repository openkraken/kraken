import { krakenWindow } from './bridge';
import { URL } from './url';
import { UnImplError } from './unimpl-error';

const krakenLocation = krakenWindow.location;
const url = new URL(krakenLocation.href);

export const location = {
  get href() {
    return krakenLocation.href;
  },
  get origin() {
    return url.origin;
  },
  get protocol() {
    return url.protocol;
  },
  get host() {
    return url.host;
  },
  get hostname() {
    return url.hostname;
  },
  get port() {
    return url.port;
  },
  get pathname() {
    return url.pathname;
  },
  get search() {
    return url.search;
  },
  get hash() {
    return url.hash;
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