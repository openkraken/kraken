describe('URLSearchParams has', () => {
  it('Has basics', function () {
    var params = new URLSearchParams('a=b&c=d');
    expect(params.has('a')).toBeTrue();
    expect(params.has('c')).toBeTrue();
    expect(params.has('e')).toBeFalse();
    params = new URLSearchParams('a=b&c=d&a=e');
    expect(params.has('a')).toBeTrue();
    params = new URLSearchParams('=b&c=d');
    expect(params.has('')).toBeTrue();
    params = new URLSearchParams('null=a');
    // @ts-ignore
    expect(params.has(null)).toBeTrue();
  });
  it('has() following delete()', function () {
    var params = new URLSearchParams('a=b&c=d&&');
    // @ts-ignore
    params.append('first', 1);
    // @ts-ignore
    params.append('first', 2);
    expect(params.has('a')).toBeTrue();
    expect(params.has('c')).toBeTrue();
    expect(params.has('first')).toBeTrue();
    expect(params.has('d')).toBeFalse();
    params.delete('first');
    expect(params.has('first')).toBeFalse();
  });
});