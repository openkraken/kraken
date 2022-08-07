/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

import { webf } from './webf';

class History {
  constructor() {
  }

  get length() {
    return Number(webf.invokeModule('History', 'length'));
  }

  get state() {
    return JSON.parse(webf.invokeModule('History', 'state'));
  }

  back() {
     webf.invokeModule('History', 'back');
  }

  forward() {
    webf.invokeModule('History', 'forward');
  }

  go(delta?: number) {
    webf.invokeModule('History', 'go', delta ? Number(delta) : null);
  }

  pushState(state: any, title: string, url?: string) {
    if (arguments.length < 2) {
      throw TypeError("Failed to execute 'pushState' on 'History': 2 arguments required, but only " + arguments.length + " present");
    }

    webf.invokeModule('History', 'pushState', [state, title, url]);
  }

  replaceState(state: any, title: string, url?: string) {
    if (arguments.length < 2) {
      throw TypeError("Failed to execute 'pushState' on 'History': 2 arguments required, but only " + arguments.length + " present");
    }

    webf.invokeModule('History', 'replaceState', [state, title, url]);
  }
}

export const history = new History();
