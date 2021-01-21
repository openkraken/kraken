describe('URLSearchParams get', () => {
  it('Get basics', function () {
    var params = new URLSearchParams('a=b&c=d');
    expect(params.get('a')).toBe('b');
    expect(params.get('c')).toBe('d');
    expect(params.get('e')).toBe(null);
    params = new URLSearchParams('a=b&c=d&a=e');
    expect(params.get('a')).toBe('b');
    params = new URLSearchParams('=b&c=d');
    expect(params.get('')).toBe('b');
    params = new URLSearchParams('a=&c=d&a=e');
    expect(params.get('a')).toBe('');
  });
  it('More get() basics', function () {
    var params = new URLSearchParams('first=second&third&&');
    expect(params != null).toBeTrue();
    expect(params.has('first')).toBeTrue();
    expect(params.get('first')).toBe(
      'second',
      'Search params object has name "first" with value "second"'
    );
    expect(params.get('third')).toBe(
      '',
      'Search params object has name "third" with the empty value.'
    );
    expect(params.get('fourth')).toBe(
      null,
      'Search params object has no "fourth" name and value.'
    );
  });
});