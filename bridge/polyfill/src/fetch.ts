import { krakenInvokeModule } from './kraken';

function normalizeName(name: any) {
  if (typeof name !== 'string') {
    name = String(name);
  }
  if (/[^a-z0-9\-#$%&'*+.^_`|~]/i.test(name) || name === '') {
    throw new TypeError('Invalid character in header field name');
  }
  return name.toLowerCase();
}

function normalizeValue(value: any) {
  if (typeof value !== 'string') {
    value = String(value);
  }
  return value;
}

class FetchHeader implements Headers {
  private map = {};

  constructor(init?: HeadersInit) { }

  append(name: string, value: string): void {
    name = normalizeName(name);
    value = normalizeValue(value);
    let oldValue = this.map[name];
    this.map[name] = oldValue ? oldValue + ', ' + value : value;
  }

  delete(name: string): void {
    delete this.map[normalizeName(name)];
  }

  forEach(callbackfn: (value: string, key: string, parent: Headers) => void, thisArg?: any): void {
    for (let name in this.map) {
      if (this.map.hasOwnProperty(name)) {
        callbackfn.call(thisArg, this.map[name], name, this);
      }
    }
  }

  get(name: string): string | null {
    name = normalizeName(name);
    return this.has(name) ? this.map[name] : null;
  }

  has(name: string): boolean {
    return this.map.hasOwnProperty(normalizeName(name));
  }

  set(name: string, value: string): void {
    this.map[normalizeName(name)] = normalizeValue(value);
  }
}

class FetchBody {
  // TODO support readableStream
  // readonly body: ReadableStream<Uint8Array> | null;
  body: string | null;
  bodyUsed: boolean;

  constructor(body?: BodyInit | null) {
    if (body) {
      this.initBody(body);
    }
  }

  initBody(body: BodyInit) {
    // only support string from now
    if (typeof body === 'string') {
      this.body = body;
    }
  }

  arrayBuffer(): Promise<ArrayBuffer> {
    throw new Error('not supported');
  }

  blob(): Promise<Blob> {
    throw new Error('not supported');
  }

  formData(): Promise<FormData> {
    throw new Error('not supported');
  }

  async json(): Promise<any> {
    if (!this.body) {
      return {};
    }

    this.bodyUsed = true;
    return JSON.parse(this.body);
  }

  async text(): Promise<string> {
    this.bodyUsed = true;
    return this.body || '';
  }
}

let methods = ['DELETE', 'GET', 'HEAD', 'OPTIONS', 'POST', 'PUT'];
function normalizeMethod(method: string) {
  let upcased = method.toUpperCase();
  return methods.indexOf(upcased) > -1 ? upcased : method;
}

class FetchRequest extends FetchBody {
  constructor(input: FetchRequest | string, init?: RequestInit) {
    if (!init) {
      init = {};
    }
    super(init.body);
    let body = init.body;

    if (input instanceof FetchRequest) {
      if (input.bodyUsed) {
        throw new TypeError('Already read');
      }
      this.url = input.url;
      if (!init.headers) {
        this.headers = new FetchHeader(input.headers);
      }
      this.method = input.method;
      this.mode = input.mode;
      if (!body && input.body != null) {
        this.body = input.body;
        input.bodyUsed = true;
      }
    } else {
      this.url = String(input);
    }

    if (init.headers || !this.headers) {
      this.headers = new FetchHeader(init.headers);
    }
    this.method = normalizeMethod(init.method || this.method || 'GET');
    this.mode = init.mode || this.mode || null;

    if ((this.method === 'GET' || this.method === 'HEAD') && body) {
      throw new TypeError('Body not allowed for GET or HEAD requests')
    }
  }

  // readonly cache: RequestCache; // not supported
  // readonly credentials: RequestCredentials; // not supported;
  // readonly destination: RequestDestination; // not supported
  // readonly integrity: string; // not supported
  // readonly isHistoryNavigation: boolean; // not supported
  // readonly isReloadNavigation: boolean; // not supported
  // readonly keepalive: boolean; // not supported
  // readonly redirect: RequestRedirect; // not supported
  // readonly referrer: string; // not supported
  // readonly referrerPolicy: ReferrerPolicy;
  // readonly signal: AbortSignal; // not supported

  readonly url: string;
  readonly method: string;
  readonly headers: Headers;
  readonly mode: RequestMode;

  clone(): FetchRequest {
    return Object.assign({}, this);
  }
}

let redirectStatuses = [301, 302, 303, 307, 308];
class FetchResponse extends FetchBody {
  static error(): FetchResponse {
    let response = new FetchResponse(null, {status: 0, statusText: ''});
    response.type = 'error';
    return response;
  };

  static redirect(url: string, status?: number): FetchResponse {
    if (!status || redirectStatuses.indexOf(status) === -1) {
      throw new RangeError('Invalid status code')
    }

    let response = new FetchResponse(null, {status: status, headers: {location: url}});
    response.redirected = true;
    return response;
  };

  // TODO support readableStream
  // readonly body: ReadableStream<Uint8Array> | null;
  body: string | null;
  bodyUsed: boolean;
  headers: Headers;
  ok: boolean;
  redirected: boolean;
  status: number;
  statusText: string;
  type: ResponseType;
  url: string;

  constructor(body?: BodyInit | null, init?: ResponseInit) {
    super(body);

    if (!init) {
      init = {};
    }

    this.type = 'default';
    this.status = init.status === undefined ? 200 : init.status;
    this.ok = this.status >= 200 && this.status < 300;
    this.statusText = 'statusText' in init ? (init.statusText || '') : 'OK';
    this.headers = new FetchHeader(init.headers);
  }

  clone(): FetchResponse {
    return Object.assign({}, this);
  }
}

function fetch(input: FetchRequest | string, init?: RequestInit) {
  return new Promise((resolve, reject) => {
    let url = typeof input === 'string' ? input : input.url;
    init = init || {method: 'GET'};

    krakenInvokeModule(`["fetch", ["${url}", ${JSON.stringify(init)}]]`, function(json) {
      var [err, statusCode, body] = JSON.parse(json);
      // network error didn't have statusCode
      if (err && !statusCode) {
        reject(new Error(err));
        return;
      }

      let res = new FetchResponse(body, {
        status: statusCode
      });

      res.url = url;

      return resolve(res);
    });
  });
}

Object.defineProperty(global, 'Request', {
  value: FetchRequest,
  enumerable: true,
  writable: false,
  configurable: false
});

Object.defineProperty(global, 'Header', {
  value: FetchHeader,
  enumerable: true,
  writable: false,
  configurable: false
});

Object.defineProperty(global, 'Response', {
  value: FetchRequest,
  enumerable: true,
  writable: false,
  configurable: false
});

Object.defineProperty(global, 'fetch', {
  value: fetch,
  enumerable: true,
  writable: false,
  configurable: false
});
