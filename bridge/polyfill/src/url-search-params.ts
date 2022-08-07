/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

// https://github.com/WebReflection/url-search-params

const find = /[!'\(\)~]|%20|%00/g;
const plus = /\+/g;
const replace = {
  '!': '%21',
  "'": '%27',
  '(': '%28',
  ')': '%29',
  '~': '%7E',
  '%20': '+',
  '%00': '\x00'
};
const replacer = function(match: string) {
  return replace[match];
};
const DICT_KEY = '__URLSearchParams__';

function encode(str: string) {
  return encodeURIComponent(str).replace(find, replacer);
}

function decode(str: string) {
  return decodeURIComponent(str.replace(plus, ' '));
}

export class URLSearchParams {
  constructor(query: any) {
    this._reset();
    if (!query) return;

    if (typeof query === 'string') {
      this._fromString(query);
    } else if(query instanceof URLSearchParams) {
      query.forEach((value, name) => {
        this.append(name, value);
      });
    } else if (Array.isArray(query)) {
      for (var i = 0, length = query.length; i < length; i++) {
        var value = query[i];
        this.append(value[0], value[1]);
      }
    } else {
      for (var key in query) {
        this.append(key, query[key]);
      }
    }
  }

  _reset() {
    this[DICT_KEY] = Object.create(null);
  }

  _fromString(query: string) {
    if (query.charAt(0) === '?') {
      query = query.slice(1);
    }
    for (var index, value, pairs = (query || '').split('&'), i = 0, length = pairs.length; i < length; i++) {
      value = pairs[i];
      index = value.indexOf('=');
      if (-1 < index) {
        this.append(
          decode(value.slice(0, index)),
          decode(value.slice(index + 1))
        );
      } else if (value.length) {
        this.append(
          decode(value),
          ''
        );
      }
    }
  }
  /**
   * Appends a specified key/value pair as a new search parameter.
   */
  append(name: string, value: string) {
    var dict = this[DICT_KEY];
    if (name in dict) {
      dict[name].push('' + value);
    } else {
      dict[name] = ['' + value];
    }
  }
  /**
   * Deletes the given search parameter, and its associated value, from the list of all search parameters.
   */
  delete(name: string) {
    delete this[DICT_KEY][name];
  }
  /**
   * Returns the first value associated to the given search parameter.
   */
  get(name: string) {
    var dict = this[DICT_KEY];
    return name in dict ? dict[name][0] : null;
  }
  /**
   * Returns all the values association with a given search parameter.
   */
  getAll(name: string) {
    var dict = this[DICT_KEY];
    return name in dict ? dict[name].slice(0) : [];
  }
  /**
   * Returns a Boolean indicating if such a search parameter exists.
   */
  has(name: string) {
    return name in this[DICT_KEY];
  }
  /**
   * Sets the value associated to a given search parameter to the given value. If there were several values, delete the others.
   */
  set(name: string, value: string) {
    this[DICT_KEY][name] = ['' + value];
  }
  /**
   * Allows iteration through all values contained in this object via a callback function.
   * @param callback A callback function that is executed against each parameter, with the param value provided as its parameter.
   * @param thisArg
   */
  forEach(callback: (value: string, key: string, parent: URLSearchParams) => void, thisArg?: any) {
    var dict = this[DICT_KEY];
    var params = this;
    Object.getOwnPropertyNames(dict).forEach(function(name) {
      dict[name].forEach(function invokeCallback(value: string) {
        callback.call(thisArg, value, name, params);
      }, params);
    }, params);
  }
  /**
   * Returns a string containing a query string suitable for use in a URL. Does not include the question mark.
   */
  toString() {
    var dict = this[DICT_KEY], query = [], i, key, name, value;
    for (key in dict) {
      name = encode(key);
      for (i = 0, value = dict[key]; i < value.length; i++) {
        query.push(name + '=' + encode(value[i]));
      }
    }
    return query.join('&');
  }
}
