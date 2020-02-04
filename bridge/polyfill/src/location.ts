import { originLocation } from './window';

export interface KrakenLocation {
  reload: () => void;
  origin: string;
  protocol: string;
  host: string;
  hostname: string;
  port: string;
  pathname: string;
  search: string;
  hash: string;
}


export class Location {
  get reload() {
    return originLocation.reload;
  }
  get origin () {
    return originLocation.origin;
  }
  get protocol () {
    return originLocation.protocol;
  }
  get host () {
    return originLocation.host;
  }
  get hostname () {
    return originLocation.hostname;
  }
  get port () {
    return originLocation.port;
  }
  get pathname () {
    return originLocation.pathname;
  }
  get search () {
    return originLocation.search;
  }
  get hash () {
    return originLocation.hash;
  }
}
