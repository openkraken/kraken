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

  it('constructor Basic URLSearchParams construction', () => {
    var params = new URLSearchParams();
    expect(params + '').toBe('');
    params = new URLSearchParams('');
    expect(params + '').toBe('');
    params = new URLSearchParams('a=b');
    expect(params + '').toBe('a=b');
    params = new URLSearchParams(params);
    expect(params + '').toBe('a=b');
  });

  it('constructor, no arguments"', async () => {
    var params = new URLSearchParams()
    expect(params.toString()).toBe('');
  });

  it(' constructor, remove leading "?"', () => {
    var params = new URLSearchParams("?a=b")
    expect(params.toString()).toBe("a=b");
  });

  it('constructor, {} as argument', () => {
    var params = new URLSearchParams({});
    expect(params + '').toBe( "");
  });

  it('constructor, string. 001', () => {
    var params = new URLSearchParams('a=b');
    expect(params != null).toBe(true, 'constructor returned non-null value.');
    expect(params.has('a')).toBe(true, 'Search params object has name "a"');
    expect(params.has('b')).toBe(false, 'Search params object has not got name "b"');
  });

  it('constructor, string. 002', () => {
    var params = new URLSearchParams('a=b&c');
    expect(params != null).toBe(true, 'constructor returned non-null value.');
    expect(params.has('a')).toBe(true, 'Search params object has name "a"');
    expect(params.has('c')).toBe(true,  'Search params object has name "c"');
  });

  it('constructor, string. 003', () => {
    var params = new URLSearchParams('&a&&& &&&&&a+b=& c&m%c3%b8%c3%b8');
    expect(params != null).toBe(true);
    expect(params.has('a')).toBe(true, 'Search params object has name "a"');
    expect(params.has('a b')).toBe(true, 'Search params object has name "a b"');
    expect(params.has(' ')).toBe(true, 'Search params object has name " "');
    expect(params.has('c')).toBe(false, 'Search params object did not have the name "c"');
    expect(params.has(' c')).toBe(true, 'Search params object has name " c"');
    expect(params.has('møø')).toBe(true, 'Search params object has name "møø"');
  });


});
