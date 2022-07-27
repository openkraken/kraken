/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

const builtInWindowEvents = [
  "onclick",
  "ondblclick",
  "onload",
  "onratechange",
  "onresize",
  "onscroll",
  "onhashchange",
  "onmessage",
  "onpopstate",
  "onrejectionhandled",
  "onunhandledrejection",
  "ontouchcancel",
  "ontouchend",
  "ontouchmove",
  "ontouchstart"
];


builtInWindowEvents.forEach(e => {
  let pKey = '_' + e;
  Object.defineProperty(window, e, {
    get(): any {
      return this[pKey];
    },
    set(value) {
      if (this[pKey]) {
        this.removeEventListener(e.substring(2), this[pKey]);
        this[pKey] = null;
      }

      this.addEventListener(e.substring(2), value);
      this[pKey] = value;
    }
  });
});

//@ts-ignore
export class ErrorEvent extends Event {
  message?: string;
  lineno?: number;
  error?: Error;
  colno?: number;
  filename?: string;

  constructor(type: string, init?: ErrorEventInit) {
    super(type);
    if (init) {
      this.message = init.message;
      this.lineno = init.lineno;
      this.error = init.error;
      this.colno = init.colno;
      this.filename = init.filename;
    }
  }
}


//@ts-ignore
export class PromiseRejectionEvent extends Event {
  promise: Promise<any>;
  reason: any;

  constructor(type: string, init?: PromiseRejectionEventInit) {
    super(type);

    if (init) {
      this.promise = init.promise;
      this.reason = init.reason;
    }
  };
}
