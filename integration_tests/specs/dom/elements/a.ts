describe('anchor element', () => {
  it('should work with set href attribute', () => {
    let a = document.createElement('a');
    a.href = 'https://v3.vuejs.org/guide/introduction.html';
    expect(a.href).toBe('https://v3.vuejs.org/guide/introduction.html');
  });

  it('should work with pathname property', () => {
    let a = document.createElement('a');
    a.href = 'https://v3.vuejs.org/guide/introduction.html';

    expect(a.pathname).toBe('/guide/introduction.html');

    a.pathname = '/guide/introduction.html#what-is-vue-js';
    expect(a.href).toBe('https://v3.vuejs.org/guide/introduction.html%23what-is-vue-js');
  });

  it('should work with host property', () => {
    let a = document.createElement('a');
    a.href = 'https://v3.vuejs.org:8093/guide/introduction.html';

    expect(a.host).toBe('v3.vuejs.org:8093');
    expect(a.hostname).toBe('v3.vuejs.org');
    expect(a.port).toBe('8093');
    a.host = 'react.dev:8088';
    expect(a.href).toBe('https://react.dev:8088/guide/introduction.html');
    a.hostname = 'v3.vuejs.org';
    expect(a.href).toBe('https://v3.vuejs.org:8088/guide/introduction.html');
  });

  it('should work with protocol property', () => {
    let a = document.createElement('a');
    a.href = 'https://v3.vuejs.org/guide/introduction.html';

    expect(a.protocol).toBe('https:');
    a.protocol = 'http:';
    expect(a.href).toBe('http://v3.vuejs.org/guide/introduction.html');
  });
});
