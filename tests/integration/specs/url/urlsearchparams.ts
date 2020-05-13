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
});
