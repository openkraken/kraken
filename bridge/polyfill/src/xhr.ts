// Forked from https://github.com/driverdan/node-XMLHttpRequest/blob/master/lib/XMLHttpRequest.js

import { URL } from './url';
import { navigator } from './navigator';
import { initPropertyHandlersForEventTargets } from './helpers';

// XHR buildin events
const builtInEvents = [
  'readystatechange',
  'load',
  'loadstart',
  'loadend',
  'abort',
  'error',
];

// Set some default headers
const defaultHeaders = {
  // Use getter instead of value for lazy read value at initialize time.
  get "User-Agent"() {
    return navigator.userAgent;
  },
  get "Accept"() {
    return "*/*";
  }
};

// These request methods are not allowed
const forbiddenRequestMethods = [
  "TRACE",
  "TRACK",
  "CONNECT"
];

export class XMLHttpRequest extends EventTarget {
  /**
   * XHR readyState
   */
  public UNSENT = 0;
  public OPENED = 1;
  public HEADERS_RECEIVED = 2;
  public LOADING = 3;
  public DONE = 4;

  // Current state
  public readyState = this.UNSENT;

  // default ready state change handler in case one is not set or is set late
  public onreadystatechange = null;

  // Result & response
  public responseText = "";
  public responseXML = "";
  public status = 0;
  public statusText = null;

  // Whether cross-site Access-Control requests should be made using
  // credentials such as cookies or authorization headers
  public withCredentials = false;

  // XHR response object
  private response: any = {};
  // XHR settings
  private settings: any = {};
  // XHR headers
  private headers: any = {};
  // XHR headers cache
  private headersCache: any = {};
  // Send flag
  private sendFlag = false;
  // Error flag, used when errors occur or abort is called
  private errorFlag = false;

  constructor() {
    // @ts-ignore
    super(builtInEvents);

    initPropertyHandlersForEventTargets(this, builtInEvents);
  }

  /**
   * Open the connection.
   *
   * @param string method Connection method (eg GET, POST)
   * @param string url URL for the connection.
   * @param boolean async Asynchronous connection. Default is true.
   * @param string user Username for basic authentication (optional)
   * @param string password Password for basic authentication (optional)
   */
  public open(
    method: string,
    url: string,
    async: boolean,
    user: string,
    password: string
  ) {
    this.abort();
    this.errorFlag = false;

    // Check for valid request method
    if (!this.isAllowedHttpMethod(method)) {
      throw new Error("SecurityError: Request method not allowed");
    }

    this.settings = {
      "method": method,
      "url": url.toString(),
      "async": (typeof async !== "boolean" ? true : async),
      "user": user || null,
      "password": password || null
    };

    this.setState(this.OPENED);
  };

  /**
   * Sets a header for the request or appends the value if one is already set.
   *
   * @param string header Header name
   * @param string value Header value
   */
  public setRequestHeader(header: string, value: string) {
    if (this.readyState !== this.OPENED) {
      throw new Error("INVALID_STATE_ERR: setRequestHeader can only be called when state is OPEN");
    }
    if (this.sendFlag) {
      throw new Error("INVALID_STATE_ERR: send flag is true");
    }
    header = this.headersCache[header.toLowerCase()] || header;
    this.headersCache[header.toLowerCase()] = header;
    // Each time you call setRequestHeader() after the first time you
    // call it, the specified text is appended to the end of the existing
    // header's content.
    this.headers[header] = this.headers[header] ? this.headers[header] + ', ' + value : value;
  };

  /**
   * Gets a header from the server response.
   *
   * @param string header Name of header to get.
   * @return string Text of the header or null if it doesn't exist.
   */
  public getResponseHeader(header: string) {
    if (typeof header === "string"
      && this.readyState > this.OPENED
      && this.response
      && this.response.headers
      && this.response.headers[header.toLowerCase()]
      && !this.errorFlag
    ) {
      return this.response.headers[header.toLowerCase()];
    }

    return null;
  };

  /**
   * Gets all the response headers.
   *
   * @return string A string with all response headers separated by CR+LF
   */
  public getAllResponseHeaders() {
    if (this.readyState < this.HEADERS_RECEIVED || this.errorFlag) {
      return "";
    }
    let result = "";

    for (let i in this.response.headers) {
      // Cookie headers are excluded
      if (i !== "set-cookie" && i !== "set-cookie2") {
        result += i + ": " + this.response.headers[i] + "\r\n";
      }
    }
    return result.substr(0, result.length - 2);
  };

  /**
   * Sends the request to the server.
   *
   * @param string data Optional data to send as request body.
   */
  public send(data: string) {
    if (this.readyState !== this.OPENED) {
      throw new Error("INVALID_STATE_ERR: connection must be opened before send() is called");
    }

    if (this.sendFlag) {
      throw new Error("INVALID_STATE_ERR: send has already been called");
    }

    let ssl = false;
    let url = new URL(this.settings.url, location.href);
    let host;
    // Determine the server
    switch (url.protocol) {
      case "https:":
        ssl = true;
        // SSL & non-SSL both need host, no break here.
      case "http:":
        host = url.hostname;
        break;

      case undefined:
      case null:
      case "":
        host = "localhost";
        break;

      default:
        throw new Error("Protocol not supported.");
    }

    // Default to port 80. If accessing localhost on another port be sure
    // to use http://localhost:port/path
    let port = url.port || (ssl ? 443 : 80);

    // Set the defaults if they haven't been set
    for (let name in defaultHeaders) {
      if (!this.headersCache[name.toLowerCase()]) {
        this.headers[name] = defaultHeaders[name];
      }
    }

    // Set the Host header or the server may reject the request
    this.headers.Host = host;
    // IPv6 addresses must be escaped with brackets
    if (url.host && url.host[0] === "[") {
      this.headers.Host = "[" + this.headers.Host + "]";
    }
    if (!((ssl && port === 443) || port === 80)) {
      this.headers.Host += ":" + url.port;
    }

    // We did't going to support basic-auth for security reasons.
    // No basic-auth implementation here.

    // Set content length header
    if (this.settings.method === "GET" || this.settings.method === "HEAD") {
      data = '';
    } else if (data) {
      if (!this.getRequestHeader("Content-Type")) {
        this.headers["Content-Type"] = "text/plain;charset=UTF-8";
      }
    }

    // Reset error flag
    this.errorFlag = false;

    // Handle async requests
    if (this.settings.async) {
      // Use the proper protocol

      // Request is being sent, set send flag
      this.sendFlag = true;

      // As per spec, this is called here for historical reasons.
      // @ts-ignore
      this.dispatchEvent(new Event("readystatechange"));

      // Handler for the response
      const responseHandler = (resp: any) => {
        // Set response var to the response we got back
        // This is so it remains accessable outside this scope
        this.response = resp;
        // Check for redirect
        // @TODO Prevent looped redirects
        if (this.response.status === 301 || this.response.status === 302 || this.response.status === 303 || this.response.status === 307) {
          // Change URL to the redirect location
          this.settings.url = this.response.headers.location;

          fetch(this.settings.url, {
            method: this.response.status === 303 ? "GET" : this.settings.method,
            headers: this.headers,
            body: data,
          }).then(function(response) {
            responseHandler(response);
            return response.text();
          }).then((text) => {
            successHandler(text);
          }).catch(function(error) {
            errorHandler(error);
          });

          // @TODO Check if an XHR event needs to be fired here
          return;
        }

        this.setState(this.HEADERS_RECEIVED);
        this.status = this.response.status;
      };

      const successHandler = (text: string) => {
        if (this.sendFlag) {
          this.responseText = text;
          this.setState(this.DONE);
          this.sendFlag = false;
        }
      };

      // Error handler for the request
      const errorHandler = (error: any) => {
        this.handleError(error);
      };

      // Create the request
      fetch(this.settings.url, {
        method: this.settings.method,
        headers: this.headers,
        body: data,
      }).then(function(response) {
        responseHandler(response);
        return response.text();
      }).then((text) => {
        successHandler(text);
      }).catch(function(error) {
        errorHandler(error);
      });

      // @ts-ignore
      this.dispatchEvent(new Event("loadstart"));
    } else { // @TODO support synchronous
    }
  };

  /**
   * Aborts a request.
   */
  public abort() {
    // Do not share the same global object.
    this.headers = Object.assign({}, defaultHeaders);
    this.status = 0;
    this.responseText = "";
    this.responseXML = "";

    this.errorFlag = true;

    if (this.readyState !== this.UNSENT
        && (this.readyState !== this.OPENED || this.sendFlag)
        && this.readyState !== this.DONE) {
      this.sendFlag = false;
      this.setState(this.DONE);
    }
    this.readyState = this.UNSENT;
    // @ts-ignore
    this.dispatchEvent(new Event("abort"));
  };

  /**
   * Check if the specified method is allowed.
   *
   * @param string method Request method to validate
   * @return boolean False if not allowed, otherwise true
   */
  private isAllowedHttpMethod(method: string) {
    return (method && forbiddenRequestMethods.indexOf(method) === -1);
  };

  /**
   * Gets a request header
   *
   * @param string name Name of header to get
   * @return string Returns the request header or empty string if not set
   */
  private getRequestHeader(name: string) {
    if (typeof name === "string" && this.headersCache[name.toLowerCase()]) {
      return this.headers[this.headersCache[name.toLowerCase()]];
    }

    return "";
  };

  /**
   * Called when an error is encountered to deal with it.
   */
  private handleError(error: any) {
    this.status = 0;
    this.statusText = error;
    this.responseText = error.stack;
    this.errorFlag = true;
    this.setState(this.DONE);
    // @ts-ignore
    this.dispatchEvent(new Event("error"));
  };

  /**
   * Changes readyState and calls onreadystatechange.
   *
   * @param int state New state
   */
  private setState(state: number) {
    if (state == this.LOADING || this.readyState !== state) {
      this.readyState = state;

      if (this.settings.async || this.readyState < this.OPENED || this.readyState === this.DONE) {
        // @ts-ignore
        this.dispatchEvent(new Event("readystatechange"));
      }

      if (this.readyState === this.DONE && !this.errorFlag) {
        // @ts-ignore
        this.dispatchEvent(new Event("load"));
        // @TODO figure out InspectorInstrumentation::didLoadXHR(cookie)
        // @ts-ignore
        this.dispatchEvent(new Event("loadend"));
      }
    }
  };
}
