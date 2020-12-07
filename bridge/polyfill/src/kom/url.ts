import { URLSearchParams } from './url-search-params';

// https://github.com/Polymer/URL
var relative = Object.create(null);
relative.ftp = 21;
relative.file = 0;
relative.gopher = 70;
relative.http = 80;
relative.https = 443;
relative.ws = 80;
relative.wss = 443;

var relativePathDotMapping = Object.create(null);
relativePathDotMapping['%2e'] = '.';
relativePathDotMapping['.%2e'] = '..';
relativePathDotMapping['%2e.'] = '..';
relativePathDotMapping['%2e%2e'] = '..';

function isRelativeScheme(scheme: string) {
  return relative[scheme] !== undefined;
}

function percentEscape(c: string) {
  var unicode = c.charCodeAt(0);
  if (unicode > 0x20 &&
     unicode < 0x7F &&
     // " # < > ? `
     [0x22, 0x23, 0x3C, 0x3E, 0x3F, 0x60].indexOf(unicode) == -1
  ) {
    return c;
  }
  return encodeURIComponent(c);
}

function percentEscapeQuery(c: string) {
  // XXX This actually needs to encode c using encoding and then
  // convert the bytes one-by-one.

  var unicode = c.charCodeAt(0);
  if (unicode > 0x20 &&
     unicode < 0x7F &&
     // " # < > ` (do not escape '?')
     [0x22, 0x23, 0x3C, 0x3E, 0x60].indexOf(unicode) == -1
  ) {
    return c;
  }
  return encodeURIComponent(c);
}

const EOF = undefined;
const ALPHA = /[a-zA-Z]/;
const ALPHANUMERIC = /[a-zA-Z0-9\+\-\.]/;

// Does not process domain names or IP addresses.
// Does not handle encoding for the query parameter.

export class URL {
  _url: string;
  _isInvalid: boolean;
  _isRelative: boolean;
  _username: string;
  _password: null | string;
  _scheme: string;
  _query: string;
  _fragment: string;
  _host: string;
  _port: string;
  _path: any[];
  _schemeData: string;
  _searchParams: URLSearchParams;
  _shouldUpdateSearchParams = true;

  constructor(url: string, base?: string | URL) {
    if (base !== undefined && !(base instanceof URL))
    base = new URL(String(base));

    this._url = url;
    this._clear();

    var input = url.replace(/^[ \t\r\n\f]+|[ \t\r\n\f]+$/g, '');
    // encoding = encoding || 'utf-8'

    this._parse(input, null, base);

    const searchParams = this._searchParams = new URLSearchParams(this.search);

    ['append', 'delete', 'set'].forEach((methodName) => {
      var method = searchParams[methodName];

      searchParams[methodName] = (...args: any) => {
        method.apply(searchParams, args);
        this._shouldUpdateSearchParams = false;
        this.search = searchParams.toString();
        this._shouldUpdateSearchParams = true;
      };
    });
  }

  private _clear() {
    this._scheme = '';
    this._schemeData = '';
    this._username = '';
    this._password = null;
    this._host = '';
    this._port = '';
    this._path = [];
    this._query = '';
    this._fragment = '';
    this._isInvalid = false;
    this._isRelative = false;
  }

  private _invalid() {
    this._clear();
    this._isInvalid = true;
  }

  private _IDNAToASCII(h: string) {
    if ('' == h) {
      this._invalid();
    }
    // XXX
    return h.toLowerCase();
  }

  private _parse(input: string, stateOverride: any, base?: any) {

    var state = stateOverride || 'scheme start',
      cursor = 0,
      buffer = '',
      seenAt = false,
      seenBracket = false,
      errors = [];

    function err(message: string) {
      errors.push(message);
    }

    loop: while ((input[cursor - 1] != EOF || cursor == 0) && !this._isInvalid) {
      var c = input[cursor];
      switch (state) {
        case 'scheme start':
          if (c && ALPHA.test(c)) {
            buffer += c.toLowerCase(); // ASCII-safe
            state = 'scheme';
          } else if (!stateOverride) {
            buffer = '';
            state = 'no scheme';
            continue;
          } else {
            err('Invalid scheme.');
            break loop;
          }
          break;

        case 'scheme':
          if (c && ALPHANUMERIC.test(c)) {
            buffer += c.toLowerCase(); // ASCII-safe
          } else if (':' == c) {
            this._scheme = buffer;
            buffer = '';
            if (stateOverride) {
              break loop;
            }
            if (isRelativeScheme(this._scheme)) {
              this._isRelative = true;
            }
            if ('file' == this._scheme) {
              state = 'relative';
            } else if (this._isRelative && base && base._scheme == this._scheme) {
              state = 'relative or authority';
            } else if (this._isRelative) {
              state = 'authority first slash';
            } else {
              state = 'scheme data';
            }
          } else if (!stateOverride) {
            buffer = '';
            cursor = 0;
            state = 'no scheme';
            continue;
          } else if (EOF == c) {
            break loop;
          } else {
            err('Code point not allowed in scheme: ' + c);
            break loop;
          }
          break;

        case 'scheme data':
          if ('?' == c) {
            state = 'query';
          } else if ('#' == c) {
            this._fragment = '#';
            state = 'fragment';
          } else {
            // XXX error handling
            if (EOF != c && '\t' != c && '\n' != c && '\r' != c) {
              this._schemeData += percentEscape(c);
            }
          }
          break;

        case 'no scheme':
          if (!base || !isRelativeScheme(base._scheme)) {
            err('Missing scheme.');
            this._invalid();
          } else {
            state = 'relative';
            continue;
          }
          break;

        case 'relative or authority':
          if ('/' == c && '/' == input[cursor + 1]) {
            state = 'authority ignore slashes';
          } else {
            err('Expected /, got: ' + c);
            state = 'relative';
            continue;
          }
          break;

        case 'relative':
          this._isRelative = true;
          if ('file' != this._scheme)
            this._scheme = base._scheme;
          if (EOF == c) {
            this._host = base._host;
            this._port = base._port;
            this._path = base._path.slice();
            this._query = base._query;
            this._username = base._username;
            this._password = base._password;
            break loop;
          } else if ('/' == c || '\\' == c) {
            if ('\\' == c)
              err('\\ is an invalid code point.');
            state = 'relative slash';
          } else if ('?' == c) {
            this._host = base._host;
            this._port = base._port;
            this._path = base._path.slice();
            this._query = '?';
            this._username = base._username;
            this._password = base._password;
            state = 'query';
          } else if ('#' == c) {
            this._host = base._host;
            this._port = base._port;
            this._path = base._path.slice();
            this._query = base._query;
            this._fragment = '#';
            this._username = base._username;
            this._password = base._password;
            state = 'fragment';
          } else {
            var nextC = input[cursor + 1];
            var nextNextC = input[cursor + 2];
            if (
              'file' != this._scheme || !ALPHA.test(c) ||
              nextC != ':' && nextC != '|' ||
              EOF != nextNextC && '/' != nextNextC && '\\' != nextNextC && '?' != nextNextC && '#' != nextNextC) {
              this._host = base._host;
              this._port = base._port;
              this._username = base._username;
              this._password = base._password;
              this._path = base._path.slice();
              this._path.pop();
            }
            state = 'relative path';
            continue;
          }
          break;

        case 'relative slash':
          if ('/' == c || '\\' == c) {
            if ('\\' == c) {
              err('\\ is an invalid code point.');
            }
            if ('file' == this._scheme) {
              state = 'file host';
            } else {
              state = 'authority ignore slashes';
            }
          } else {
            if ('file' != this._scheme) {
              this._host = base._host;
              this._port = base._port;
              this._username = base._username;
              this._password = base._password;
            }
            state = 'relative path';
            continue;
          }
          break;

        case 'authority first slash':
          if ('/' == c) {
            state = 'authority second slash';
          } else {
            err("Expected '/', got: " + c);
            state = 'authority ignore slashes';
            continue;
          }
          break;

        case 'authority second slash':
          state = 'authority ignore slashes';
          if ('/' != c) {
            err("Expected '/', got: " + c);
            continue;
          }
          break;

        case 'authority ignore slashes':
          if ('/' != c && '\\' != c) {
            state = 'authority';
            continue;
          } else {
            err('Expected authority, got: ' + c);
          }
          break;

        case 'authority':
          if ('@' == c) {
            if (seenAt) {
              err('@ already seen.');
              buffer += '%40';
            }
            seenAt = true;
            for (var i = 0; i < buffer.length; i++) {
              var cp = buffer[i];
              if ('\t' == cp || '\n' == cp || '\r' == cp) {
                err('Invalid whitespace in authority.');
                continue;
              }
              // XXX check URL code points
              if (':' == cp && null === this._password) {
                this._password = '';
                continue;
              }
              var tempC = percentEscape(cp);
              null !== this._password ? this._password += tempC : this._username += tempC;
            }
            buffer = '';
          } else if (EOF == c || '/' == c || '\\' == c || '?' == c || '#' == c) {
            cursor -= buffer.length;
            buffer = '';
            state = 'host';
            continue;
          } else {
            buffer += c;
          }
          break;

        case 'file host':
          if (EOF == c || '/' == c || '\\' == c || '?' == c || '#' == c) {
            if (buffer.length == 2 && ALPHA.test(buffer[0]) && (buffer[1] == ':' || buffer[1] == '|')) {
              state = 'relative path';
            } else if (buffer.length == 0) {
              state = 'relative path start';
            } else {
              this._host = this._IDNAToASCII(buffer);
              buffer = '';
              state = 'relative path start';
            }
            continue;
          } else if ('\t' == c || '\n' == c || '\r' == c) {
            err('Invalid whitespace in file host.');
          } else {
            buffer += c;
          }
          break;

        case 'host':
        case 'hostname':
          if (':' == c && !seenBracket) {
            // XXX host parsing
            this._host = this._IDNAToASCII(buffer);
            buffer = '';
            state = 'port';
            if ('hostname' == stateOverride) {
              break loop;
            }
          } else if (EOF == c || '/' == c || '\\' == c || '?' == c || '#' == c) {
            this._host = this._IDNAToASCII(buffer);
            buffer = '';
            state = 'relative path start';
            if (stateOverride) {
              break loop;
            }
            continue;
          } else if ('\t' != c && '\n' != c && '\r' != c) {
            if ('[' == c) {
              seenBracket = true;
            } else if (']' == c) {
              seenBracket = false;
            }
            buffer += c;
          } else {
            err('Invalid code point in host/hostname: ' + c);
          }
          break;

        case 'port':
          if (/[0-9]/.test(c)) {
            buffer += c;
          } else if (EOF == c || '/' == c || '\\' == c || '?' == c || '#' == c || stateOverride) {
            if ('' != buffer) {
              var temp = parseInt(buffer, 10);
              if (temp != relative[this._scheme]) {
                this._port = temp + '';
              }
              buffer = '';
            }
            if (stateOverride) {
              break loop;
            }
            state = 'relative path start';
            continue;
          } else if ('\t' == c || '\n' == c || '\r' == c) {
            err('Invalid code point in port: ' + c);
          } else {
            this._invalid();
          }
          break;

        case 'relative path start':
          if ('\\' == c)
            err("'\\' not allowed in path.");
          state = 'relative path';
          if ('/' != c && '\\' != c) {
            continue;
          }
          break;

        case 'relative path':
          if (EOF == c || '/' == c || '\\' == c || !stateOverride && ('?' == c || '#' == c)) {
            if ('\\' == c) {
              err('\\ not allowed in relative path.');
            }
            var tmp;
            if (tmp = relativePathDotMapping[buffer.toLowerCase()]) {
              buffer = tmp;
            }
            if ('..' == buffer) {
              this._path.pop();
              if ('/' != c && '\\' != c) {
                this._path.push('');
              }
            } else if ('.' == buffer && '/' != c && '\\' != c) {
              this._path.push('');
            } else if ('.' != buffer) {
              if ('file' == this._scheme && this._path.length == 0 && buffer.length == 2 && ALPHA.test(buffer[0]) && buffer[1] == '|') {
                buffer = buffer[0] + ':';
              }
              this._path.push(buffer);
            }
            buffer = '';
            if ('?' == c) {
              this._query = '?';
              state = 'query';
            } else if ('#' == c) {
              this._fragment = '#';
              state = 'fragment';
            }
          } else if ('\t' != c && '\n' != c && '\r' != c) {
            buffer += percentEscape(c);
          }
          break;

        case 'query':
          if (!stateOverride && '#' == c) {
            this._fragment = '#';
            state = 'fragment';
          } else if (EOF != c && '\t' != c && '\n' != c && '\r' != c) {
            this._query += percentEscapeQuery(c);
          }
          break;

        case 'fragment':
          if (EOF != c && '\t' != c && '\n' != c && '\r' != c) {
            this._fragment += c;
          }
          break;
      }

      cursor++;
    }
  }

  get href() {
    if (this._isInvalid)
      return this._url;

    var authority = '';
    if ('' != this._username || null != this._password) {
      authority = this._username +
          (null != this._password ? ':' + this._password : '') + '@';
    }

    return this.protocol +
        (this._isRelative ? '//' + authority + this.host : '') +
        this.pathname + this._query + this._fragment;
  }

  set href(href) {
    this._clear();
    this._parse(href, null);
  }

  get protocol() {
    return this._scheme + ':';
  }

  set protocol(protocol) {
    if (this._isInvalid)
      return;
    this._parse(protocol + ':', 'scheme start');
  }

  get host() {
    return this._isInvalid ? '' : this._port ?
      this._host + ':' + this._port : this._host;
  }
  set host(host) {
    if (this._isInvalid || !this._isRelative)
      return;
    this._parse(host, 'host');
  }

  get hostname() {
    return this._host;
  }
  set hostname(hostname) {
    if (this._isInvalid || !this._isRelative)
      return;
    this._parse(hostname, 'hostname');
  }

  get port() {
    return this._port;
  }
  set port(port) {
    if (this._isInvalid || !this._isRelative)
      return;
    this._parse(port, 'port');
  }

  get pathname() {
    return this._isInvalid ? '' : this._isRelative ?
      '/' + this._path.join('/') : this._schemeData;
  }
  set pathname(pathname) {
    if (this._isInvalid || !this._isRelative)
      return;
    this._path = [];
    this._parse(pathname, 'relative path start');
  }

  get search() {
    return this._isInvalid || !this._query || '?' == this._query ?
      '' : this._query;
  }
  set search(search: string) {
    if (this._isInvalid || !this._isRelative)
      return;

    search = '' + search;
    if (search == '') {
      this._query = search;
    } else {
      this._query = '?';
    }

    if ('?' == search[0])
      search = search.slice(1);
    this._parse(search, 'query');

    if (this._shouldUpdateSearchParams) {
      // @ts-ignore
      this._searchParams._reset();
      // @ts-ignore
      this._searchParams._fromString(this.search);
    }
  }

  get searchParams() {
    return this._searchParams;
  }

  get hash() {
    return this._isInvalid || !this._fragment || '#' == this._fragment ?
      '' : this._fragment;
  }
  set hash(hash) {
    if (this._isInvalid)
      return;
    this._fragment = '#';
    if ('#' == hash[0])
      hash = hash.slice(1);
    this._parse(hash, 'fragment');
  }

  get origin() {
    var host;
    if (this._isInvalid || !this._scheme) {
      return '';
    }
    // javascript: Gecko returns String(""), WebKit/Blink String("null")
    // Gecko throws error for "data://"
    // data: Gecko returns "", Blink returns "data://", WebKit returns "null"
    // Gecko returns String("") for file: mailto:
    // WebKit/Blink returns String("SCHEME://") for file: mailto:
    switch (this._scheme) {
      case 'data':
      case 'file':
      case 'javascript':
      case 'mailto':
        return 'null';
    }
    host = this.host;
    if (!host) {
      return '';
    }
    return this._scheme + '://' + host;
  }

  toString() {
    return this.href;
  }
}
