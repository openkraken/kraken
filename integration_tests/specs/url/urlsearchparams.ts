describe('URLSearchParams', () => {
  [
    {"input": "test", "output": [["test", ""]]},
    {"input": "\uFEFFtest=\uFEFF", "output": [["\uFEFFtest", "\uFEFF"]]},
    {"input": "%EF%BB%BFtest=%EF%BB%BF", "output": [["\uFEFFtest", "\uFEFF"]]},
    {"input": '', "output": []},
    {"input": 'a', "output": [['a', '']]},
    {"input": 'a=b', "output": [['a', 'b']]},
    {"input": 'a=', "output": [['a', '']]},
    {"input": '=b', "output": [['', 'b']]},
    {"input": '&', "output": []},
    {"input": '&a', "output": [['a', '']]},
    {"input": 'a&', "output": [['a', '']]},
    {"input": 'a&a', "output": [['a', ''], ['a', '']]},
    {"input": 'a&b&c', "output": [['a', ''], ['b', ''], ['c', '']]},
    {"input": 'a=b&c=d', "output": [['a', 'b'], ['c', 'd']]},
    {"input": 'a=b&c=d&', "output": [['a', 'b'], ['c', 'd']]},
    {"input": '&&&a=b&&&&c=d&', "output": [['a', 'b'], ['c', 'd']]},
    {"input": 'a=a&a=b&a=c', "output": [['a', 'a'], ['a', 'b'], ['a', 'c']]},
    {"input": 'a==a', "output": [['a', '=a']]},
    {"input": 'a=a+b+c+d', "output": [['a', 'a b c d']]},
    {"input": '%61=a', "output": [['a', 'a']]},
    {"input": '%61+%4d%4D=', "output": [['a MM', '']]}
  ].forEach((val) => {
    it('URLSearchParams constructed with: ' + val.input, () => {
      let sp = new URLSearchParams(val.input);
      let i = 0;
      sp.forEach((value, key) => {
        expect([key, value]).toEqual(val.output[i]);
        i++;
      });
    });
  });

  it('constructor', () => {
    var a = new URLSearchParams('b=1&a=2&c=3');
    expect(a.toString()).toBe('b=1&a=2&c=3');

    var b = new URLSearchParams(a);
    expect(b.toString()).toBe('b=1&a=2&c=3');
    
    // @ts-ignore
    var c = new URLSearchParams([['b', 1], ['a', 2], ['c', 3]]);
    expect(c.toString()).toBe('b=1&a=2&c=3');

    // @ts-ignore
    var d = new URLSearchParams({ 'b': 1, 'a': 2, 'c': 3 });
    expect(d.toString()).toBe('b=1&a=2&c=3');
  });

  it('basics', ()=>{
    var usp = new URLSearchParams('a=1&b=2&c');

    expect(usp.has('a') && usp.has('b') && usp.has('c')).toBe(true);
    expect(usp.get('a') === '1').toBe(true);
    expect(usp.get('b') === '2').toBe(true);
    expect(usp.get('c') === '').toBe(true);
    expect(usp.getAll('a').join(',') === '1').toBe(true);
    expect(usp.getAll('b').join(',') === '2').toBe(true);
    expect(usp.getAll('c').join(',') === '').toBe(true);

    usp.append('a', '3');
    expect(usp.getAll('a').join(',') === '1,3').toBe(true);
    expect(usp.get('a') === '1').toBe(true);
    expect(usp.getAll('b').join(',') === '2' && usp.getAll('c').join(',') === '').toBe(true);

    usp.set('a', '4');
    expect(usp.getAll('a').join(',') === '4').toBe(true);

    usp.delete('a');
    expect(usp.has('a') === false).toBe(true);
    expect(usp.get('a') === null).toBe(true);
    expect(usp.toString() === 'b=2&c=').toBe(true);
  });

  it('append same name', () => {
    let params = new URLSearchParams();
    params.append('a', 'b');
    expect(params + '').toBe('a=b');
    params.append('a', 'b');
    expect(params + '', ).toBe('a=b&a=b');
    params.append('a', 'c');
    expect(params + '').toBe('a=b&a=b&a=c');
  });

  it('append empty strings', () => {
    var params = new URLSearchParams();
    params.append('', '');
    expect(params + '').toBe('=');
    params.append('', '');
    expect(params + '').toBe('=&=');
  });

  it('append null', () => {
    var params = new URLSearchParams();
    // @ts-ignore
    params.append(null, null);
    expect(params + '').toBe('null=null');
    // @ts-ignore
    params.append(null, null);
    expect(params + '').toBe( 'null=null&null=null');
  });

  it('append multiple', () => {
    var params = new URLSearchParams();
    // @ts-ignore
    params.append('first', 1);
    // @ts-ignore
    params.append('second', 2);
    // @ts-ignore
    params.append('third', '');
    // @ts-ignore
    params.append('first', 10);
    expect(params.has('first')).toBe(true);
    expect(params.get('first')).toBe('1');
    expect(params.get('second')).toBe('2');
    expect(params.get('third')).toBe('');
    // @ts-ignore
    params.append('first', 10);
    expect(params.get('first')).toBe('1');
  });

  it('Set basics', function () {
    var params = new URLSearchParams('a=b&c=d');
    params.set('a', 'B');
    expect(params + '').toBe('a=B&c=d');
    params = new URLSearchParams('a=b&c=d&a=e');
    params.set('a', 'B');
    expect(params + '').toBe('a=B&c=d');
    params.set('e', 'f');
    expect(params + '').toBe('a=B&c=d&e=f');
  });
  it('URLSearchParams.set', function () {
    var params = new URLSearchParams('a=1&a=2&a=3');
    expect(params.has('a')).toBeTrue();
    expect(params.get('a')).toBe(
      '1',
      'Search params object has name "a" with value "1"'
    );
    // @ts-ignore
    params.set('first', 4);
    expect(params.has('a')).toBeTrue();
    expect(params.get('a')).toBe(
      '1',
      'Search params object has name "a" with value "1"'
    );
    // @ts-ignore
    params.set('a', 4);
    expect(params.has('a')).toBeTrue();
    expect(params.get('a')).toBe(
      '4',
      'Search params object has name "a" with value "4"'
    );
  });
  [
    {
      input: 'z=b&a=b&z=a&a=a',
      output: [
        ['a', 'b'],
        ['a', 'a'],
        ['z', 'b'],
        ['z', 'a'],
      ],
    },
    {
      input: '\uFFFD=x&\uFFFC&\uFFFD=a',
      output: [
        ['\uFFFC', ''],
        ['\uFFFD', 'x'],
        ['\uFFFD', 'a'],
      ],
    },
    {
      input: 'ﬃ&\uD83C\uDF08',
      output: [
        ['\uD83C\uDF08', ''],
        ['ﬃ', ''],
      ],
    },
    {
      input: 'é&e\uFFFD&é',
      output: [
        ['é', ''],
        ['e\uFFFD', ''],
        ['é', ''],
      ],
    },
    {
      input: 'z=z&a=a&z=y&a=b&z=x&a=c&z=w&a=d&z=v&a=e&z=u&a=f&z=t&a=g',
      output: [
        ['a', 'a'],
        ['a', 'b'],
        ['a', 'c'],
        ['a', 'd'],
        ['a', 'e'],
        ['a', 'f'],
        ['a', 'g'],
        ['z', 'z'],
        ['z', 'y'],
        ['z', 'x'],
        ['z', 'w'],
        ['z', 'v'],
        ['z', 'u'],
        ['z', 't'],
      ],
    },
    {
      input: 'bbb&bb&aaa&aa=x&aa=y',
      output: [
        ['aa', 'x'],
        ['aa', 'y'],
        ['aaa', ''],
        ['bb', ''],
        ['bbb', ''],
      ],
    },
    {
      input: 'z=z&=f&=t&=x',
      output: [
        ['', 'f'],
        ['', 't'],
        ['', 'x'],
        ['z', 'z'],
      ],
    },
    {
      input: 'a\uD83C\uDF08&a\uD83D\uDCA9',
      output: [
        ['a\uD83C\uDF08', ''],
        ['a\uD83D\uDCA9', ''],
      ],
    },
  ].forEach((val) => {
    xit('Parse and sort: ' + val.input, () => {
      let params = new URLSearchParams(val.input),
        i = 0;
      params.sort();
      // @ts-ignore
      for (let param of params) {
        expect(param).toEqual(val.output[i]);
        i++;
      }
    });
    xit('URL parse and sort: ' + val.input, () => {
      let url = new URL('?' + val.input, 'https://example/');
      url.searchParams.sort();
      let params = new URLSearchParams(url.search),
        i = 0;
      // @ts-ignore
      for (let param of params) {
        expect(param).toEqual(val.output[i]);
        i++;
      }
    });
  });
  xit('Sorting non-existent params removes ? from URL', function () {
    const url = new URL('http://example.com/?');
    url.searchParams.sort();
    expect(url.href).toBe('http://example.com/');
    expect(url.search).toBe('');
  });

  it('Serialize space', function () {
    var params = new URLSearchParams();
    params.append('a', 'b c');
    expect(params + '').toBe('a=b+c');
    params.delete('a');
    params.append('a b', 'c');
    expect(params + '').toBe('a+b=c');
  });
  it('Serialize empty value', function () {
    var params = new URLSearchParams();
    params.append('a', '');
    expect(params + '').toBe('a=');
    params.append('a', '');
    expect(params + '').toBe('a=&a=');
    params.append('', 'b');
    expect(params + '').toBe('a=&a=&=b');
    params.append('', '');
    expect(params + '').toBe('a=&a=&=b&=');
    params.append('', '');
    expect(params + '').toBe('a=&a=&=b&=&=');
  });
  it('Serialize empty name', function () {
    var params = new URLSearchParams();
    params.append('', 'b');
    expect(params + '').toBe('=b');
    params.append('', 'b');
    expect(params + '').toBe('=b&=b');
  });
  it('Serialize empty name and value', function () {
    var params = new URLSearchParams();
    params.append('', '');
    expect(params + '').toBe('=');
    params.append('', '');
    expect(params + '').toBe('=&=');
  });
  it('Serialize +', function () {
    var params = new URLSearchParams();
    params.append('a', 'b+c');
    expect(params + '').toBe('a=b%2Bc');
    params.delete('a');
    params.append('a+b', 'c');
    expect(params + '').toBe('a%2Bb=c');
  });
  it('Serialize =', function () {
    var params = new URLSearchParams();
    params.append('=', 'a');
    expect(params + '').toBe('%3D=a');
    params.append('b', '=');
    expect(params + '').toBe('%3D=a&b=%3D');
  });
  it('Serialize &', function () {
    var params = new URLSearchParams();
    params.append('&', 'a');
    expect(params + '').toBe('%26=a');
    params.append('b', '&');
    expect(params + '').toBe('%26=a&b=%26');
  });
  it('Serialize *-._', function () {
    var params = new URLSearchParams();
    params.append('a', '*-._');
    expect(params + '').toBe('a=*-._');
    params.delete('a');
    params.append('*-._', 'c');
    expect(params + '').toBe('*-._=c');
  });
  it('Serialize %', function () {
    var params = new URLSearchParams();
    params.append('a', 'b%c');
    expect(params + '').toBe('a=b%25c');
    params.delete('a');
    params.append('a%b', 'c');
    expect(params + '').toBe('a%25b=c');
  });
  xit('Serialize \\0', function () {
    var params = new URLSearchParams();
    params.append('a', 'b\0c');
    expect(params + '').toBe('a=b%00c');
    params.delete('a');
    params.append('a\0b', 'c');
    expect(params + '').toBe('a%00b=c');
  });
  it('Serialize \uD83D\uDCA9', function () {
    var params = new URLSearchParams();
    params.append('a', 'b\uD83D\uDCA9c');
    expect(params + '').toBe('a=b%F0%9F%92%A9c');
    params.delete('a');
    params.append('a\uD83D\uDCA9b', 'c');
    expect(params + '').toBe('a%F0%9F%92%A9b=c');
  });
  it('URLSearchParams.toString', function () {
    var params;
    params = new URLSearchParams('a=b&c=d&&e&&');
    expect(params.toString()).toBe('a=b&c=d&e=');
    params = new URLSearchParams('a = b &a=b&c=d%20');
    expect(params.toString()).toBe('a+=+b+&a=b&c=d+');
    params = new URLSearchParams('a=&a=b');
    expect(params.toString()).toBe('a=&a=b');
  });
  it('URLSearchParams connected to URL', () => {
    const url = new URL('http://www.example.com/?a=b,c');
    const params = url.searchParams;
    expect(url.toString()).toBe('http://www.example.com/?a=b,c');
    expect(params.toString()).toBe('a=b%2Cc');
    params.append('x', 'y');
    expect(url.toString()).toBe('http://www.example.com/?a=b%2Cc&x=y');
    expect(params.toString()).toBe('a=b%2Cc&x=y');
  });

  it('should encoding/decoding special char', () => {
    var params = new URLSearchParams('a=2018-12-19T09:14:35%2B09:00');
    expect(params.get('a')).toBe('2018-12-19T09:14:35+09:00');

    var params2 = new URLSearchParams('a=one+two');
    expect(params2.get('a')).toBe('one two');
  });

});
