describe('URlSearchParams delete', () => {
  it('Basic URLSearchParams construction', function () {
    var params = new URLSearchParams();
    expect(params + '').toBe('');
    params = new URLSearchParams('');
    expect(params + '').toBe('');
    params = new URLSearchParams('a=b');
    expect(params + '').toBe('a=b');
    params = new URLSearchParams(params);
    expect(params + '').toBe('a=b');
  });
  it('URLSearchParams constructor, no arguments', function () {
    var params = new URLSearchParams();
    expect(params.toString()).toBe('');
  });
  it('URLSearchParams constructor, remove leading "?"', function () {
    var params = new URLSearchParams('?a=b');
    expect(params.toString()).toBe('a=b');
  });
  xit('URLSearchParams constructor, DOMException as argument', () => {
    // @ts-ignore
    var params = new URLSearchParams(DOMException);
    expect(params.toString()).toBe(
      'INDEX_SIZE_ERR=1&DOMSTRING_SIZE_ERR=2&HIERARCHY_REQUEST_ERR=3&WRONG_DOCUMENT_ERR=4&INVALID_CHARACTER_ERR=5&NO_DATA_ALLOWED_ERR=6&NO_MODIFICATION_ALLOWED_ERR=7&NOT_FOUND_ERR=8&NOT_SUPPORTED_ERR=9&INUSE_ATTRIBUTE_ERR=10&INVALID_STATE_ERR=11&SYNTAX_ERR=12&INVALID_MODIFICATION_ERR=13&NAMESPACE_ERR=14&INVALID_ACCESS_ERR=15&VALIDATION_ERR=16&TYPE_MISMATCH_ERR=17&SECURITY_ERR=18&NETWORK_ERR=19&ABORT_ERR=20&URL_MISMATCH_ERR=21&QUOTA_EXCEEDED_ERR=22&TIMEOUT_ERR=23&INVALID_NODE_TYPE_ERR=24&DATA_CLONE_ERR=25'
    );
  });
  it('URLSearchParams constructor, empty string as argument', () => {
    var params = new URLSearchParams('');
    expect(params != null).toBeTrue();
    // @ts-ignore
    expect(params.__proto__).toBe(
      URLSearchParams.prototype,
      'expected URLSearchParams.prototype as prototype.'
    );
  });
  it('URLSearchParams constructor, {} as argument', () => {
    var params = new URLSearchParams({});
    expect(params + '').toBe('');
  });
  it('URLSearchParams constructor, string.', function () {
    var params = new URLSearchParams('a=b');
    expect(params != null).toBeTrue();
    expect(params.has('a')).toBeTrue();
    expect(params.has('b')).toBeFalse();
    params = new URLSearchParams('a=b&c');
    expect(params != null).toBeTrue();
    expect(params.has('a')).toBeTrue();
    expect(params.has('c')).toBeTrue();
    params = new URLSearchParams('&a&&& &&&&&a+b=& c&m%c3%b8%c3%b8');
    expect(params != null).toBeTrue();
    expect(params.has('a')).toBeTrue();
    expect(params.has('a b')).toBeTrue();
    expect(params.has(' ')).toBeTrue();
    expect(params.has('c')).toBeFalse();
    expect(params.has(' c')).toBeTrue();
    expect(params.has('møø')).toBeTrue();
  });
  it('URLSearchParams constructor, object.', function () {
    var seed = new URLSearchParams('a=b&c=d');
    var params = new URLSearchParams(seed);
    expect(params != null).toBeTrue();
    expect(params.get('a')).toBe('b');
    expect(params.get('c')).toBe('d');
    expect(params.has('d')).toBeFalse();
    seed.append('e', 'f');
    expect(params.has('e')).toBeFalse();
    params.append('g', 'h');
    expect(seed.has('g')).toBeFalse();
  });
  xit('URLSearchParams constructor, FormData.', function () {
    var formData = new FormData();
    formData.append('a', 'b');
    formData.append('c', 'd');
    // @ts-ignore
    var params = new URLSearchParams(formData);
    expect(params != null).toBeTrue();
    expect(params.get('a')).toBe('b');
    expect(params.get('c')).toBe('d');
    expect(params.has('d')).toBeFalse();
    formData.append('e', 'f');
    expect(params.has('e')).toBeFalse();
    params.append('g', 'h');
    expect(formData.has('g')).toBeFalse();
  });
  it('Parse +', function () {
    var params = new URLSearchParams('a=b+c');
    expect(params.get('a')).toBe('b c');
    params = new URLSearchParams('a+b=c');
    expect(params.get('a b')).toBe('c');
  });
  it('Parse encoded +', function () {
    const testValue = '+15555555555';
    const params = new URLSearchParams();
    params.set('query', testValue);
    var newParams = new URLSearchParams(params.toString());
    expect(params.toString()).toBe('query=%2B15555555555');
    expect(params.get('query')).toBe(testValue);
    expect(newParams.get('query')).toBe(testValue);
  });
  it('Parse space', function () {
    var params = new URLSearchParams('a=b c');
    expect(params.get('a')).toBe('b c');
    params = new URLSearchParams('a b=c');
    expect(params.get('a b')).toBe('c');
  });
  it('Parse %20', function () {
    var params = new URLSearchParams('a=b%20c');
    expect(params.get('a')).toBe('b c');
    params = new URLSearchParams('a%20b=c');
    expect(params.get('a b')).toBe('c');
  });
  it('Parse \\0', function () {
    var params = new URLSearchParams('a=b\0c');
    expect(params.get('a')).toBe('b\0c');
    params = new URLSearchParams('a\0b=c');
    expect(params.get('a\0b')).toBe('c');
  });
  it('Parse %00', function () {
    var params = new URLSearchParams('a=b%00c');
    expect(params.get('a')).toBe('b\0c');
    params = new URLSearchParams('a%00b=c');
    expect(params.get('a\0b')).toBe('c');
  });
  it('Parse \u2384', function () {
    var params = new URLSearchParams('a=b\u2384');
    expect(params.get('a')).toBe('b\u2384');
    params = new URLSearchParams('a\u2384b=c');
    expect(params.get('a\u2384b')).toBe('c');
  });
  it('Parse %e2%8e%84', function () {
    var params = new URLSearchParams('a=b%e2%8e%84');
    expect(params.get('a')).toBe('b\u2384');
    params = new URLSearchParams('a%e2%8e%84b=c');
    expect(params.get('a\u2384b')).toBe('c');
  });
  it('Parse \uD83D\uDCA9', function () {
    var params = new URLSearchParams('a=b\uD83D\uDCA9c');
    expect(params.get('a')).toBe('b\uD83D\uDCA9c');
    params = new URLSearchParams('a\uD83D\uDCA9b=c');
    expect(params.get('a\uD83D\uDCA9b')).toBe('c');
  });
  it('Parse %f0%9f%92%a9', function () {
    var params = new URLSearchParams('a=b%f0%9f%92%a9c');
    expect(params.get('a')).toBe('b\uD83D\uDCA9c');
    params = new URLSearchParams('a%f0%9f%92%a9b=c');
    expect(params.get('a\uD83D\uDCA9b')).toBe('c');
  });
  it('Constructor with sequence of sequences of strings', function () {
    var params = new URLSearchParams([]);
    expect(params != null).toBeTrue();
    params = new URLSearchParams([
      ['a', 'b'],
      ['c', 'd'],
    ]);
    expect(params.get('a')).toBe('b');
    expect(params.get('c')).toBe('d');
  });
  [
    {
      input: { '+': '%C2' },
      output: [['+', '%C2']],
      name: 'object with +',
    },
    {
      input: {
        c: 'x',
        a: '?',
      },
      output: [
        ['c', 'x'],
        ['a', '?'],
      ],
      name: 'object with two keys',
    },
    {
      input: [
        ['c', 'x'],
        ['a', '?'],
      ],
      output: [
        ['c', 'x'],
        ['a', '?'],
      ],
      name: 'array with two keys',
    },
    {
      input: {
        'a\0b': '42',
        'c\uD83D': '23',
        dሴ: 'foo',
      },
      output: [
        ['a\0b', '42'],
        ['c\uFFFD', '23'],
        ['dሴ', 'foo'],
      ],
      name: 'object with NULL, non-ASCII, and surrogate keys',
    },
  ].forEach((val) => {
    xit('Construct with ' + val.name, () => {
      // @ts-ignore
      let params = new URLSearchParams(val.input),
        i = 0;
      // @ts-ignore
      for (let param of params) {
        expect(param).toEqual(val.output[i]);
        i++;
      }
    }, );
  });
  xit('Custom [Symbol.iterator]', () => {
    var params = new URLSearchParams();
    params[Symbol.iterator] = function* () {
      yield ['a', 'b'];
    };
    let params2 = new URLSearchParams(params);
    expect(params2.get('a')).toBe('b');
  });

});