describe('URLSearchParams', () => {
  it('should encoding/decoding special char', () => {
    var params = new URLSearchParams('a=2018-12-19T09:14:35%2B09:00');
    expect(params.get('a')).toBe('2018-12-19T09:14:35+09:00');

    var params2 = new URLSearchParams('a=one+two');
    expect(params2.get('a')).toBe('one two');
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
  }) 
});
