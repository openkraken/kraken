describe('Headers', () => {
  it('constructor copies headers', function () {
    let original = new Headers()
    original.append('Accept', 'application/json');
    original.append('Accept', 'text/plain');
    original.append('Content-Type', 'text/html');

    let headers = new Headers(original);
    assert.equal(headers.get('Accept'), 'application/json, text/plain');
    assert.equal(headers.get('Content-type'), 'text/html');
  });
  it('constructor works with arrays', function () {
    let array = [['Content-Type', 'text/xml'], ['Breaking-Bad', '<3']];
    let headers = new Headers(array);

    assert.equal(headers.get('Content-Type'), 'text/xml');
    assert.equal(headers.get('Breaking-Bad'), '<3');
  });
  it('headers are case insensitive', function () {
    let headers = new Headers({Accept: 'application/json'});
    assert.equal(headers.get('ACCEPT'), 'application/json');
    assert.equal(headers.get('Accept'), 'application/json');
    assert.equal(headers.get('accept'), 'application/json');
  });
  it('appends to existing', function () {
    let headers = new Headers({Accept: 'application/json'});
    assert.equal(headers.has('Content-Type'), false);
    headers.append('Content-Type', 'application/json');
    assert.equal(headers.has('Content-Type'), true);
    assert.equal(headers.get('Content-Type'), 'application/json');
  });
  it('appends values to existing header name', function () {
    let headers = new Headers({Accept: 'application/json'});
    headers.append('Accept', 'text/plain');
    assert.equal(headers.get('Accept'), 'application/json, text/plain');
  });
  it('sets header name and value', function () {
    let headers = new Headers();
    headers.set('Content-Type', 'application/json');
    assert.equal(headers.get('Content-Type'), 'application/json');
  });
  it('returns null on no header found', function () {
    let headers = new Headers();
    assert.strictEqual(headers.get('Content-Type'), null);
  });
  it('has headers that are set', function () {
    let headers = new Headers();
    headers.set('Content-Type', 'application/json');
    assert.strictEqual(headers.has('Content-Type'), true);
  });
  it('deletes headers', function () {
    let headers = new Headers()
    headers.set('Content-Type', 'application/json');
    assert.strictEqual(headers.has('Content-Type'), true);
    headers.delete('Content-Type')
    assert.strictEqual(headers.has('Content-Type'), false);
    assert.strictEqual(headers.get('Content-Type'), null);
  });
  it('converts field name to string on set and get', function () {
    let headers = new Headers();
    headers.set(1, 'application/json');
    assert.strictEqual(headers.has('1'), true);
    assert.equal(headers.get(1), 'application/json');
  });
  it('converts field value to string on set and get', function () {
    let headers = new Headers();
    headers.set('Content-Type', 1);
    headers.set('X-CSRF-Token', undefined);
    assert.equal(headers.get('Content-Type'), '1');
    assert.equal(headers.get('X-CSRF-Token'), 'undefined');
  });
  it('throws TypeError on invalid character in field name', function () {
    assert.throws(function () {
      new Headers({'[Accept]': 'application/json'})
    }, TypeError);
    assert.throws(function () {
      new Headers({'Accept:': 'application/json'})
    }, TypeError);
    assert.throws(function () {
      let headers = new Headers()
      headers.set({field: 'value'}, 'application/json')
    }, TypeError);
    assert.throws(function () {
      new Headers({'': 'application/json'})
    }, TypeError);
  });
});

describe('Request', () => {
  it('construct with string url', function() {
    let request = new Request('https://fetch.spec.whatwg.org/');
    assert.equal(request.url, 'https://fetch.spec.whatwg.org/');
  });

  it('construct with non-Request object', function() {
    let url = {
      toString: function() {
        return 'https://fetch.spec.whatwg.org/'
      }
    };
    let request = new Request(url);
    assert.equal(request.url, 'https://fetch.spec.whatwg.org/');
  });

  it('construct with Request', function() {
    let request1 = new Request('https://fetch.spec.whatwg.org/', {
      method: 'post',
      body: 'I work out',
      headers: {
        accept: 'application/json',
        'Content-Type': 'text/plain'
      }
    });
    let request2 = new Request(request1);

    return request2.text().then(function(body2) {
      assert.equal(body2, 'I work out');
      assert.equal(request2.method, 'POST');
      assert.equal(request2.url, 'https://fetch.spec.whatwg.org/');
      assert.equal(request2.headers.get('accept'), 'application/json');
      assert.equal(request2.headers.get('content-type'), 'text/plain');

      return request1.text().then(
        function() {
          assert(false, 'original request body should have been consumed')
        },
        function(error) {
          assert(error instanceof TypeError, 'expected TypeError for already read body')
        }
      )
    });
  });

  it('construct with Request and override headers', function() {
    let request1 = new Request('https://fetch.spec.whatwg.org/', {
      method: 'post',
      body: 'I work out',
      headers: {
        accept: 'application/json',
        'X-Request-ID': '123'
      }
    });
    let request2 = new Request(request1, {
      headers: {'x-it': '42'}
    });

    assert.equal(request2.headers.get('accept'), undefined);
    assert.equal(request2.headers.get('x-request-id'), undefined);
    assert.equal(request2.headers.get('x-it'), '42');
  });

  it('construct with Request and override body', function() {
    let request1 = new Request('https://fetch.spec.whatwg.org/', {
      method: 'post',
      body: 'I work out',
      headers: {
        'Content-Type': 'text/plain'
      }
    });
    let request2 = new Request(request1, {
      body: '{"wiggles": 5}',
      headers: {'Content-Type': 'application/json'}
    });

    return request2.json().then(function(data) {
      assert.equal(data.wiggles, 5);
      assert.equal(request2.headers.get('content-type'), 'application/json');
    });
  });

  it('construct with used Request body', function() {
    let request1 = new Request('https://fetch.spec.whatwg.org/', {
      method: 'post',
      body: 'I work out'
    });

    return request1.text().then(function() {
      assert.throws(function() {
        new Request(request1)
      }, TypeError)
    });
  });

  it('GET should not have implicit Content-Type', function() {
    let req = new Request('https://fetch.spec.whatwg.org/');
    assert.equal(req.headers.get('content-type'), undefined);
  });

  it('POST with blank body should not have implicit Content-Type', function() {
    let req = new Request('https://fetch.spec.whatwg.org/', {
      method: 'post'
    });
    assert.equal(req.headers.get('content-type'), undefined);
  });

  it('construct with string body sets Content-Type header', function() {
    let req = new Request('https://fetch.spec.whatwg.org/', {
      method: 'post',
      body: 'I work out'
    });

    assert.equal(req.headers.get('content-type'), 'text/plain;charset=UTF-8');
  });

  it('construct with body and explicit header uses header', function() {
    let req = new Request('https://fetch.spec.whatwg.org/', {
      method: 'post',
      headers: {'Content-Type': 'image/png'},
      body: 'I work out'
    });

    assert.equal(req.headers.get('content-type'), 'image/png');
  });

  it('construct with unsupported body type', function() {
    let req = new Request('https://fetch.spec.whatwg.org/', {
      method: 'post',
      body: {}
    });

    assert.equal(req.headers.get('content-type'), 'text/plain;charset=UTF-8')
    return req.text().then(function(bodyText) {
      assert.equal(bodyText, '[object Object]')
    });
  });

  it('construct with null body', function() {
    let req = new Request('https://fetch.spec.whatwg.org/', {
      method: 'post'
    });

    assert.equal(req.headers.get('content-type'), null);
    return req.text().then(function(bodyText) {
      assert.equal(bodyText, '')
    });
  });

  it('clone GET request', function() {
    let req = new Request('https://fetch.spec.whatwg.org/', {
      headers: {'content-type': 'text/plain'}
    });
    let clone = req.clone();

    assert.equal(clone.url, req.url);
    assert.equal(clone.method, 'GET');
    assert.equal(clone.headers.get('content-type'), 'text/plain');
    assert.notEqual(clone.headers, req.headers);
    console.assert(req.bodyUsed === true);
  });

  it('clone POST request', function() {
    let req = new Request('https://fetch.spec.whatwg.org/', {
      method: 'post',
      headers: {'content-type': 'text/plain'},
      body: 'I work out'
    });
    let clone = req.clone();

    assert.equal(clone.method, 'POST');
    assert.equal(clone.headers.get('content-type'), 'text/plain');
    assert.notEqual(clone.headers, req.headers);
    assert.equal(req.bodyUsed, false);

    return Promise.all([clone.text(), req.clone().text()]).then(function(bodies) {
      assert.deepEqual(bodies, ['I work out', 'I work out'])
    });
  });
});