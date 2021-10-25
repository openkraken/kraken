describe('URL', () => {
  it('without base', async () => {
    var url = new URL('https://www.example.com:80/?test=foo_bar&type=baz#page0');
    expect(url.hash).toBe('#page0');
    expect(url.host).toBe('www.example.com:80');
    expect(url.hostname).toBe('www.example.com');
    expect(url.href).toBe('https://www.example.com:80/?test=foo_bar&type=baz#page0');
    expect(url.origin).toBe('https://www.example.com:80');
    expect(url.pathname).toBe('/');
    expect(url.port).toBe('80');
    expect(url.protocol).toBe('https:');
    expect(url.search).toBe('?test=foo_bar&type=baz');
    url.searchParams.append('page', '1');
    expect(url.search).toBe('?test=foo_bar&type=baz&page=1');
    url.searchParams.delete('type');
    expect(url.search).toBe('?test=foo_bar&page=1');
  });

  it('with base', () => {
    var url = new URL('test', 'https://www.example.com/base');
    expect(url.host).toBe('www.example.com');
    expect(url.hostname).toBe('www.example.com');
    expect(url.href).toBe('https://www.example.com/test');
    expect(url.pathname).toBe('/test');
    expect(url.protocol).toBe('https:');
    expect(url.search).toBe('');
  });

  it('set pathname variations', () => {
    var url = new URL('test/long/path.html', 'https://www.example.com');
    expect(url.pathname).toBe('/test/long/path.html');
    url.pathname = 'a/b 1';
    expect(url.pathname).toBe('/a/b%201');
  });

  it('set search params', () => {
    var url = new URL('https://www.example.com/?');
    expect(url.toString()).toBe('https://www.example.com/?');
    expect(url.search).toBe('');
    expect(url.searchParams).toEqual(url.searchParams);

    url.search = 'c=b';
    expect(url.searchParams.toString()).toBe('c=b');

    url.searchParams.append('d', 'e');
    expect(url.search).toBe('?c=b&d=e');

    url.search = '';
    expect(url.searchParams.toString()).toBe('');
    expect(url.toString()).toBe('https://www.example.com/');

    url.searchParams.append('d', 'e');
    expect(url.search).toBe('?d=e');
  });

  it('protocol should control the visibility of port in origin', () => {
    var url = new URL('https://www.example.com:443'); // No port for https on 443
    var url2 = new URL('http://www.example.com:8080'); // Port for http on 8080
    var url3 = new URL('https://www.example.com:80'); // port for https on 80

    expect(url.origin).toBe('https://www.example.com');
    expect(url2.origin).toBe('http://www.example.com:8080');
    expect(url3.origin).toBe('https://www.example.com:80');
  });

  it('search params should have spaces encoded as "+"', () => {
    var url = new URL('https://www.example.com/');
    url.searchParams.set('foo', 'value with spaces');
    expect(url.toString()).toBe('https://www.example.com/?foo=value+with+spaces');
    var url = new URL('https://www.example.com/?foo=another+value+with+spaces');
    var fooParam = url.searchParams.get('foo');
    expect(fooParam).toBe('another value with spaces');
  });

  it('does not finish with ? if url.search is empty', () => {
    var url = new URL('https://www.example.com/');
    url.searchParams.delete('foo');
    expect(url.toString()).toBe('https://www.example.com/');

    var url2 = new URL('https://www.example.com/?');
    url2.searchParams.delete('foo');
    expect(url2.toString()).toBe('https://www.example.com/');
  });

  it('should handle with emoji in query', () => {
    var url = new URL('https://www.example.com/path?wd=Hello👿World');
    expect(url.search).toEqual('?wd=Hello%F0%9F%91%BFWorld');
  });

});
