
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
