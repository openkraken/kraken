describe('URLSearchParams foreach', () => {
  it('ForEach Check', function () {
    var params = new URLSearchParams('a=1&b=2&c=3');
    var keys = [];
    var values = [];
    params.forEach(function (value, key) {
      // @ts-ignore
      keys.push(key);
      // @ts-ignore
      values.push(value);
    });
    // @ts-ignore
    expect(keys).toEqual(['a', 'b', 'c']);
    // @ts-ignore
    expect(values).toEqual(['1', '2', '3']);
  });
  xit('For-of Check', function () {
    let a = new URL('http://a.b/c?a=1&b=2&c=3&d=4');
    let b = a.searchParams;
    var c = [];
    // @ts-ignore
    for (let i of b) {
      a.search = 'x=1&y=2&z=3';
      // @ts-ignore
      c.push(i);
    }
    expect(c[0]).toEqual(['a', '1']);
    expect(c[1]).toEqual(['y', '2']);
    expect(c[2]).toEqual(['z', '3']);
  });
  xit('delete next param during iteration', function () {
    const url = new URL('http://localhost/query?param0=0&param1=1&param2=2');
    const searchParams = url.searchParams;
    const seen = [];
    // @ts-ignore
    for (let param of searchParams) {
      if (param[0] === 'param0') {
        searchParams.delete('param1');
      }
      // @ts-ignore
      seen.push(param);
    }
    expect(seen[0]).toEqual(['param0', '0']);
    expect(seen[1]).toEqual(['param2', '2']);
  });
  xit('delete current param during iteration', function () {
    const url = new URL('http://localhost/query?param0=0&param1=1&param2=2');
    const searchParams = url.searchParams;
    const seen = [];
    // @ts-ignore
    for (let param of searchParams) {
      if (param[0] === 'param0') {
        searchParams.delete('param0');
      } else {
        // @ts-ignore
        seen.push(param);
      }
    }
    expect(seen[0]).toEqual(['param2', '2']);
  });
  xit('delete every param seen during iteration', function () {
    const url = new URL('http://localhost/query?param0=0&param1=1&param2=2');
    const searchParams = url.searchParams;
    const seen = [];
    // @ts-ignore
    for (let param of searchParams) {
      // @ts-ignore
      seen.push(param[0]);
      searchParams.delete(param[0]);
    }
    expect(seen).toEqual(
      // @ts-ignore
      ['param0', 'param2'],
      'param1 should not have been seen by the loop'
    );
    expect(String(searchParams)).toBe('param1=1', 'param1 should remain');
  });
});