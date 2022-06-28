describe('Headers', () => {
  it('constructor copies headers', function() {
    let original = new Headers();
    original.append('Accept', 'application/json');
    original.append('Accept', 'text/plain');
    original.append('Content-Type', 'text/html');

    let headers = new Headers(original);
    expect(headers.get('Accept')).toBe('application/json, text/plain');
    expect(headers.get('Content-Type')).toBe('text/html');
  });
  it('constructor works with arrays', function() {
    let array = [
      ['Content-Type', 'text/xml'],
      ['Breaking-Bad', '<3'],
    ];
    let headers = new Headers(array);

    expect(headers.get('Content-Type')).toBe('text/xml');
    expect(headers.get('Breaking-Bad')).toBe('<3');
  });
  it('headers are case insensitive', function() {
    let headers = new Headers({ Accept: 'application/json' });
    expect(headers.get('ACCEPT')).toBe('application/json');
    expect(headers.get('Accept')).toBe('application/json');
    expect(headers.get('accept')).toBe('application/json');
  });
  it('appends to existing', function() {
    let headers = new Headers({ Accept: 'application/json' });
    expect(headers.has('Content-Type')).toBe(false);
    headers.append('Content-Type', 'application/json');
    expect(headers.has('Content-Type')).toBe(true);
    expect(headers.get('Content-Type')).toBe('application/json');
  });
  it('appends values to existing header name', function() {
    let headers = new Headers({ Accept: 'application/json' });
    headers.append('Accept', 'text/plain');
    expect(headers.get('Accept')).toBe('application/json, text/plain');
  });
  it('sets header name and value', function() {
    let headers = new Headers();
    headers.set('Content-Type', 'application/json');
    expect(headers.get('Content-Type')).toBe('application/json');
  });
  it('returns null on no header found', function() {
    let headers = new Headers();
    expect(headers.get('Content-Type')).toBe(null);
  });
  it('has headers that are set', function() {
    let headers = new Headers();
    headers.set('Content-Type', 'application/json');
    expect(headers.has('Content-Type')).toBe(true);
  });
  it('deletes headers', function() {
    let headers = new Headers();
    headers.set('Content-Type', 'application/json');
    expect(headers.has('Content-Type')).toBe(true);
    headers.delete('Content-Type');
    expect(headers.has('Content-Type')).toBe(false);
    expect(headers.get('Content-Type')).toBe(null);
  });
  it('converts field name to string on set and get', function() {
    let headers = new Headers();
    // @ts-ignore
    headers.set(1, 'application/json');
    expect(headers.has('1')).toBe(true);
    // @ts-ignore
    expect(headers.get(1)).toBe('application/json');
  });
  it('converts field value to string on set and get', function() {
    let headers = new Headers();
    // @ts-ignore
    headers.set('Content-Type', 1);
    // @ts-ignore
    headers.set('X-CSRF-Token', undefined);
    expect(headers.get('Content-Type')).toBe('1');
    expect(headers.get('X-CSRF-Token')).toBe('undefined');
  });
  it('throws TypeError on invalid character in field name', function() {
    expect(function() {
      new Headers({ '[Accept]': 'application/json' });
    }).toThrowError(TypeError);
    expect(function() {
      new Headers({ 'Accept:': 'application/json' });
    }).toThrowError(TypeError);
    expect(function() {
      let headers = new Headers();
      // @ts-ignore
      headers.set({ field: 'value' }, 'application/json');
    }).toThrowError(TypeError);
    expect(function() {
      new Headers({ '': 'application/json' });
    }).toThrowError(TypeError);
  });
});

describe('Request', () => {
  it('construct with string url', function() {
    let request = new Request('https://fetch.spec.whatwg.org/');
    expect(request.url).toBe('https://fetch.spec.whatwg.org/');
  });

  it('construct with non-Request object', function() {
    let url = {
      toString: function() {
        return 'https://fetch.spec.whatwg.org/';
      },
    };
    // @ts-ignore
    let request = new Request(url);
    expect(request.url).toBe('https://fetch.spec.whatwg.org/');
  });

  it('construct with Request', function() {
    let request1 = new Request('https://fetch.spec.whatwg.org/', {
      method: 'post',
      body: 'I work out',
      headers: {
        accept: 'application/json',
        'Content-Type': 'text/plain',
      },
    });
    let request2 = new Request(request1);

    return request2.text().then(function(body2) {
      expect(body2).toBe('I work out');
      expect(request2.method).toBe('POST');
      expect(request2.url).toBe('https://fetch.spec.whatwg.org/');
      expect(request2.headers.get('accept')).toBe('application/json');
      expect(request2.headers.get('content-type')).toBe('text/plain');

      return request1.text().then(
        function() {
          console.assert(
            false,
            'original request body should have been consumed'
          );
        },
        function(error) {
          console.assert(
            error instanceof TypeError,
            'expected TypeError for already read body'
          );
        }
      );
    });
  });

  it('construct with Request and override headers', function() {
    let request1 = new Request('https://fetch.spec.whatwg.org/', {
      method: 'post',
      body: 'I work out',
      headers: {
        accept: 'application/json',
        'X-Request-ID': '123',
      },
    });
    let request2 = new Request(request1, {
      headers: { 'x-it': '42' },
    });

    // @ts-ignore
    expect(request2.headers.get('accept')).toBe(null);
    // @ts-ignore
    expect(request2.headers.get('x-request-id')).toBe(null);
    expect(request2.headers.get('x-it')).toBe('42');
  });

  it('construct with Request and override body', function() {
    let request1 = new Request('https://fetch.spec.whatwg.org/', {
      method: 'post',
      body: 'I work out',
      headers: {
        'Content-Type': 'text/plain',
      },
    });
    let request2 = new Request(request1, {
      body: '{"wiggles": 5}',
      headers: { 'Content-Type': 'application/json' },
    });

    return request2.json().then(function(data) {
      expect(data.wiggles).toBe(5);
      expect(request2.headers.get('content-type')).toBe('application/json');
    });
  });

  it('construct with used Request body', function() {
    let request1 = new Request('https://fetch.spec.whatwg.org/', {
      method: 'post',
      body: 'I work out',
    });

    return request1.text().then(function() {
      expect(function() {
        new Request(request1);
      }).toThrowError(TypeError);
    });
  });

  it('GET should not have implicit Content-Type', function() {
    let req = new Request('https://fetch.spec.whatwg.org/');
    expect(req.headers.get('content-type')).toBe(null);
  });

  it('POST with blank body should not have implicit Content-Type', function() {
    let req = new Request('https://fetch.spec.whatwg.org/', {
      method: 'post',
    });
    expect(req.headers.get('content-type')).toBe(null);
  });

  it('construct with string body sets Content-Type header', function() {
    let req = new Request('https://fetch.spec.whatwg.org/', {
      method: 'post',
      body: 'I work out',
    });

    expect(req.headers.get('content-type')).toBe('text/plain;charset=UTF-8');
  });

  it('construct with body and explicit header uses header', function() {
    let req = new Request('https://fetch.spec.whatwg.org/', {
      method: 'post',
      headers: { 'Content-Type': 'image/png' },
      body: 'I work out',
    });

    expect(req.headers.get('content-type')).toBe('image/png');
  });

  it('construct with unsupported body type', function() {
    // @ts-ignore
    let req = new Request('https://fetch.spec.whatwg.org/', {
      method: 'post',
      // @ts-ignore
      body: {},
    });

    expect(req.headers.get('content-type')).toBe('text/plain;charset=UTF-8');
    return req.text().then((bodyText: string) => {
      expect(bodyText).toBe('[object Object]');
    });
  });

  it('construct with null body', function() {
    let req = new Request('https://fetch.spec.whatwg.org/', {
      method: 'post',
    });

    expect(req.headers.get('content-type')).toBe(null);
    return req.text().then(function(bodyText) {
      expect(bodyText).toBe('');
    });
  });

  it('clone GET request', function() {
    let req = new Request('https://fetch.spec.whatwg.org/', {
      headers: { 'content-type': 'text/plain' },
    });
    let clone = req.clone();

    expect(clone.url).toBe(req.url);
    expect(clone.method).toBe('GET');
    expect(clone.headers.get('content-type')).toBe('text/plain');
    expect(clone.headers != req.headers).toBe(true);
    expect(req.bodyUsed).toBe(false);
  });

  it('clone POST request', function() {
    let req = new Request('https://fetch.spec.whatwg.org/', {
      method: 'post',
      headers: { 'content-type': 'text/plain' },
      body: 'I work out',
    });
    let clone = req.clone();

    expect(clone.method).toBe('POST');
    expect(clone.headers.get('content-type')).toBe('text/plain');
    expect(clone.headers != req.headers).toBe(true);
    expect(req.bodyUsed).toBe(false);

    return Promise.all([clone.text(), req.clone().text()]).then(function(
      bodies
    ) {
      expect(bodies).toEqual(['I work out', 'I work out']);
    });
  });
});

describe('Response', function() {
  it('default status is 200 OK', function() {
    let res = new Response();
    expect(res.status).toBe(200);
    expect(res.statusText).toBe('OK');
    expect(res.ok).toBe(true);
  });

  it('default status is 200 OK when an explicit undefined status code is passed', function() {
    let res = new Response('', { status: undefined });
    expect(res.status).toBe(200);
    expect(res.statusText).toBe('OK');
    expect(res.ok).toBe(true);
  });

  it('creates Headers object from raw headers', function() {
    let r = new Response('{"foo":"bar"}', {
      headers: { 'content-type': 'application/json' },
    });
    expect(r.headers instanceof Headers).toBe(true);
    return r.json().then(function(json) {
      expect(json.foo).toBe('bar');
      return json;
    });
  });

  it('always creates a new Headers instance', function() {
    let headers = new Headers({ 'x-hello': 'world' });
    let res = new Response('', { headers: headers });

    expect(res.headers.get('x-hello')).toBe('world');
    expect(res.headers != headers).toBe(true);
  });

  it('clone text response', function() {
    let res = new Response('{"foo":"bar"}', {
      headers: { 'content-type': 'application/json' },
    });
    let clone = res.clone();

    expect(clone.headers != res.headers).toBe(true);
    expect(clone.headers.get('content-type')).toBe('application/json');

    return Promise.all([clone.json(), res.json()]).then(function(jsons) {
      expect(jsons[0]).toEqual(
        jsons[1],
        'json of cloned object is the same as original'
      );
    });
  });

  it('error creates error Response', function() {
    let r = Response.error();
    console.assert(r instanceof Response);
    expect(r.status).toBe(0);
    expect(r.statusText).toBe('');
    expect(r.type).toBe('error');
  });

  it('redirect creates redirect Response', function() {
    let r = Response.redirect('https://fetch.spec.whatwg.org/', 301);
    console.assert(r instanceof Response);
    expect(r.status).toBe(301);
    expect(r.headers.get('Location')).toBe('https://fetch.spec.whatwg.org/');
  });

  it('construct with string body sets Content-Type header', function() {
    let r = new Response('I work out');
    expect(r.headers.get('content-type')).toBe('text/plain;charset=UTF-8');
  });

  it('construct with body and explicit header uses header', function() {
    let r = new Response('I work out', {
      headers: {
        'Content-Type': 'text/plain',
      },
    });

    expect(r.headers.get('content-type')).toBe('text/plain');
  });

  it('init object as first argument', function() {
    // @ts-ignore
    let r = new Response({
      // @ts-ignore
      status: 201,
      headers: {
        'Content-Type': 'text/html',
      },
    });

    expect(r.status).toBe(200);
    expect(r.headers.get('content-type')).toBe('text/plain;charset=UTF-8');
    return r.text().then(function(bodyText: string) {
      expect(bodyText).toBe('[object Object]');
    });
  });

  it('null as first argument', function() {
    let r = new Response(null);

    expect(r.headers.get('content-type')).toBe(null);
    return r.text().then(function(bodyText) {
      expect(bodyText).toBe('');
    });
  });

  describe('json', () => {
    it('parses json response', function() {
      return fetch('https://https://andycall.oss-cn-beijing.aliyuncs.com/data/data.json')
        .then(function(response) {
          return response.json();
        })
        .then(function(json) {
          expect(json.method).toBe('GET');
          expect(json.data.userName).toBe('12345');
        });
    });

    it('rejects json promise after body is consumed', function() {
      return fetch('/json')
        .then(function(response) {
          console.assert(response.json, 'Body does not implement json');
          expect(response.bodyUsed).toBe(false);
          response.text();
          expect(response.bodyUsed).toBe(true);
          return response.json();
        })
        .catch(function(error) {
          console.assert(
            error instanceof Error,
            'Promise rejected after body consumed'
          );
        });
    });
  });

  describe('text', function() {
    it('resolves text promise', function() {
      return fetch('https://https://andycall.oss-cn-beijing.aliyuncs.com/data/data.json')
        .then(function(response) {
          return response.text();
        })
        .then(function(text) {
          expect(text.replace(/\s+/g, '')).toBe(
            '{"method":"GET","data":{"userName":"12345"}}'
          );
        });
    });
  });
});
