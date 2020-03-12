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

