import { krakenWindow } from './bridge';
const krakenLocation = krakenWindow.location;

const location = {
  get reload() {
    return krakenLocation.reload;
  },
  get origin () {
    return krakenLocation.origin;
  },
  get protocol () {
    return krakenLocation.protocol;
  },
  get host () {
    return krakenLocation.host;
  },
  get hostname () {
    return krakenLocation.hostname;
  },
  get port () {
    return krakenLocation.port;
  },
  get pathname () {
    return krakenLocation.pathname;
  },
  get search () {
    return krakenLocation.search;
  },
  get hash () {
    return krakenLocation.hash;
  }
}

Object.defineProperty(global, 'location', {
  enumerable: true,
  writable: false,
  value: location,
  configurable: false
});
