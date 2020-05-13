import { krakenWindow } from './bridge';
import { URL } from './url';

const krakenLocation = krakenWindow.location;

class Location {
  private url: URL;
  href: string;
  constructor(href: string) {
    this.href = href;
    this.url = new URL(href);
  }
  get origin() {
    return this.url.origin;
  }
  get protocol() {
    return this.url.protocol;
  }
  get host() {
    return this.url.host;
  }
  get hostname() {
    return this.url.hostname;
  }
  get port() {
    return this.url.port;
  }
  get pathname() {
    return this.url.pathname;
  }
  get search() {
    return this.url.search;
  }
  get hash() {
    return this.url.hash;
  }
  reload() {
    return krakenLocation.reload();
  }
}

export const location = new Location(krakenLocation.href);