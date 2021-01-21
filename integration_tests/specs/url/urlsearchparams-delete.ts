describe('URLSearchParams delete', () => {
  it('Delete basics', function () {
    var params = new URLSearchParams('a=b&c=d');
    params.delete('a');
    expect(params + '').toBe('c=d');
    params = new URLSearchParams('a=a&b=b&a=a&c=c');
    params.delete('a');
    expect(params + '').toBe('b=b&c=c');
    params = new URLSearchParams('a=a&=&b=b&c=c');
    params.delete('');
    expect(params + '').toBe('a=a&b=b&c=c');
    params = new URLSearchParams('a=a&null=null&b=b');
    // @ts-ignore
    params.delete(null);
    expect(params + '').toBe('a=a&b=b');
    params = new URLSearchParams('a=a&undefined=undefined&b=b');
    // @ts-ignore
    params.delete(undefined);
    expect(params + '').toBe('a=a&b=b');
  });
  it('Deleting appended multiple', function () {
    var params = new URLSearchParams();
    // @ts-ignore
    params.append('first', 1);
    expect(params.has('first')).toBeTrue();
    expect(params.get('first')).toBe(
      '1',
      'Search params object has name "first" with value "1"'
    );
    params.delete('first');
    expect(params.has('first')).toBeFalse();
    // @ts-ignore
    params.append('first', 1);
    // @ts-ignore
    params.append('first', 10);
    params.delete('first');
    expect(params.has('first')).toBeFalse();
  });
  it('Deleting all params removes ? from URL', function () {
    var url = new URL('http://example.com/?param1&param2');
    url.searchParams.delete('param1');
    url.searchParams.delete('param2');
    expect(url.href).toBe('http://example.com/', 'url.href does not have ?');
    expect(url.search).toBe('', 'url.search does not have ?');
  });
  it('Removing non-existent param removes ? from URL', function () {
    var url = new URL('http://example.com/?');
    url.searchParams.delete('param1');
    expect(url.href).toBe('http://example.com/', 'url.href does not have ?');
    expect(url.search).toBe('', 'url.search does not have ?');
  });
});