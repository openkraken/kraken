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

export class PopStateEvent extends Event {
  state: any;

  constructor(type: string, init: PopStateEventInit) {
    super(type);

    if (init) {
      this.state = init.state;
    }
  }
}
