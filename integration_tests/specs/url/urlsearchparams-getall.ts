describe('URLSearchParams getAll', () => {
  it('getAll() basics', function () {
    var params = new URLSearchParams('a=b&c=d');
    expect(params.getAll('a')).toEqual(['b']);
    expect(params.getAll('c')).toEqual(['d']);
    expect(params.getAll('e')).toEqual([]);
    params = new URLSearchParams('a=b&c=d&a=e');
    expect(params.getAll('a')).toEqual(['b', 'e']);
    params = new URLSearchParams('=b&c=d');
    expect(params.getAll('')).toEqual(['b']);
    params = new URLSearchParams('a=&c=d&a=e');
    expect(params.getAll('a')).toEqual(['', 'e']);
  });
  it('getAll() multiples', function () {
    var params = new URLSearchParams('a=1&a=2&a=3&a');
    expect(params.has('a')).toBeTrue();
    var matches = params.getAll('a');
    expect(matches && matches.length == 4).toBeTrue();
    expect(matches).toEqual(
      ['1', '2', '3', ''],
      'Search params object has expected name "a" values'
    );
    params.set('a', 'one');
    expect(params.get('a')).toBe(
      'one',
      'Search params object has name "a" with value "one"'
    );
    var matches = params.getAll('a');
    expect(matches && matches.length == 1).toBeTrue();
    expect(matches).toEqual(
      ['one'],
      'Search params object has expected name "a" values'
    );
  });
});