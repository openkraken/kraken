import { kraken } from './kraken';

class History {
  constructor() {
  }

  get length() {
    return Number(kraken.invokeModule('History', 'length'));
  }

  get state() {
    return JSON.parse(kraken.invokeModule('History', 'state'));
  }

  back() {
     kraken.invokeModule('History', 'back');
  }

  forward() {
    kraken.invokeModule('History', 'forward');
  }

  go(delta?: number) {
    kraken.invokeModule('History', 'go', delta ? Number(delta) : null);
  }

  pushState(state: any, title: string, url?: string) {
    if (arguments.length < 2) {
      throw TypeError("Failed to execute 'pushState' on 'History': 2 arguments required, but only " + arguments.length + " present");
    }

    kraken.invokeModule('History', 'pushState', [state, title, url]);
  }

  replaceState(state: any, title: string, url?: string) {
    if (arguments.length < 2) {
      throw TypeError("Failed to execute 'pushState' on 'History': 2 arguments required, but only " + arguments.length + " present");
    }

    kraken.invokeModule('History', 'replaceState', [state, title, url]);
  }
}

export const history = new History();
