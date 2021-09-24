/**
 * Test DOM API for
 * - document.querySelector
 * - document.querySelectorAll
 */
describe('querySelector api', () => {
  it('document querySelector cant find element', () => {
    ['red', 'black', 'green', 'yellow', 'blue'].forEach((item, index) => {
      const div = document.createElement('div')
      div.style.width = '100px';
      div.style.height = '100px';
      div.style.backgroundColor = item;
      div.setAttribute('id', `id-${index}`);
      document.body.appendChild(div);
    });

    expect(document.querySelector('span')).toBeNull();
  });

  it('document querySelector find first element', () => {
    ['red', 'black', 'green', 'yellow', 'blue'].forEach((item, index) => {
      const div = document.createElement('div')
      div.style.width = '100px';
      div.style.height = '100px';
      div.style.backgroundColor = item;
      div.setAttribute('id', `id-${index}`);
      document.body.appendChild(div);
    });

    const ele = document.querySelector('div');
    expect(ele?.getAttribute('id')).toBe('id-0');
  });

  it('document querySelectorAll length of elements', () => {
    const szEle = ['red', 'black', 'green', 'yellow', 'blue'];
    szEle.forEach((item, index) => {
      const div = document.createElement('div')
      div.style.width = '100px';
      div.style.height = '100px';
      div.style.backgroundColor = item;
      div.setAttribute('id', `id-${index}`);
      document.body.appendChild(div);
    });

    const eles = document.querySelectorAll('div');
    expect(eles.length).toBe(szEle.length);
  });

  it('document querySelectorAll first element', () => {
    const szEle = ['red', 'black', 'green', 'yellow', 'blue'];
    szEle.forEach((item, index) => {
      const div = document.createElement('div')
      div.style.width = '100px';
      div.style.height = '100px';
      div.style.backgroundColor = item;
      div.setAttribute('id', `id-${index}`);
      document.body.appendChild(div);
    });

    const eles = document.querySelectorAll('div');
    expect(eles[0].getAttribute('id')).toBe('id-0');
  });

  it('document querySelectorAll cant find element by tag name', () => {
    ['red', 'black', 'green', 'yellow', 'blue'].forEach((item, index) => {
      const div = document.createElement('div')
      div.style.width = '100px';
      div.style.height = '100px';
      div.style.backgroundColor = item;
      div.setAttribute('id', `id-${index}`);
      document.body.appendChild(div);
    });

    expect(document.querySelectorAll('span').length).toBe(0);
  });

  it('document querySelector find element by id', () => {
    ['red', 'black', 'green', 'yellow', 'blue'].forEach((item, index) => {
      const div = document.createElement('div')
      div.style.width = '100px';
      div.style.height = '100px';
      div.style.backgroundColor = item;
      div.setAttribute('id', `id-${index}`);
      document.body.appendChild(div);
    });

    expect(document.querySelector('#id-1')?.style.backgroundColor).toBe('black');
  });

  it('document querySelector find element by className', () => {
    ['red', 'black', 'green', 'yellow', 'blue'].forEach((item, index) => {
      const div = document.createElement('div')
      div.style.width = '100px';
      div.style.height = '100px';
      div.style.backgroundColor = item;
      div.setAttribute('id', `id-${index}`);
      div.className = `class-${index} cc`;
      document.body.appendChild(div);
    });

    expect(document.querySelector('.class-2')?.style.backgroundColor).toBe('green');
  });

  it('document querySelectorAll find all element', () => {
    ['red', 'black', 'green', 'yellow', 'blue'].forEach((item, index) => {
      const div = document.createElement('div')
      div.style.width = '100px';
      div.style.height = '100px';
      div.style.backgroundColor = item;
      div.setAttribute('id', `id-${index}`);
      div.className = `class-${index} cc`;
      document.body.appendChild(div);
    });

    expect(document.querySelectorAll('*').length).toBe(8);
  });

  it('querySelectorAll work with query attr', () => {
    ['red', 'black', 'green', 'yellow', 'blue'].forEach((item, index) => {
      const div = document.createElement('div')
      div.style.width = '100px';
      div.style.height = '100px';
      div.style.backgroundColor = item;

      div.setAttribute('id', `id-${index}`);
      div.setAttribute('data-test', `attr-${index}`);
      document.body.appendChild(div);
    });

    expect(document.querySelectorAll('div[data-test="attr-1"]')?.length).toBe(1);
  });

  it('querySelectorAll work with query relative href of attrs with *', () => {
    const a = document.createElement('a');
    a.setAttribute('href', 'openkraken.com');
    a.text = 'openkraken.com';
    document.body.appendChild(a);

    const path = document.createElement('a');
    path.setAttribute('href', '/path');
    path.text = 'path';
    document.body.appendChild(path);

    expect(document.querySelectorAll('a[href*="/path"]').length).toBe(1);
  });

  it('querySelectorAll work with query relative href of attrs with ^', () => {
    const a = document.createElement('a');
    a.setAttribute('href', 'openkraken.com');
    a.text = 'openkraken.com';
    document.body.appendChild(a);

    const path = document.createElement('a');
    path.setAttribute('href', '/path');
    path.text = 'path';
    document.body.appendChild(path);

    expect(document.querySelectorAll('a[href^="/"]').length).toBe(1);
  });

  it('querySelectorAll work with query relative href of attrs with ^ and complete string', () => {
    const a = document.createElement('a');
    a.setAttribute('href', 'openkraken.com');
    a.text = 'openkraken.com';
    document.body.appendChild(a);

    const path = document.createElement('a');
    path.setAttribute('href', '/path');
    path.text = 'path';
    document.body.appendChild(path);

    expect(document.querySelectorAll('a[href^="/path"]').length).toBe(1);
  });

  it('querySelectorAll work with query relative href of attrs with $', () => {
    const a = document.createElement('a');
    a.setAttribute('href', 'openkraken.com');
    a.text = 'openkraken.com';
    document.body.appendChild(a);

    const path = document.createElement('a');
    path.setAttribute('href', '/path');
    path.text = 'path';
    document.body.appendChild(path);

    expect(document.querySelectorAll('a[href$="th"]').length).toBe(1);
  });

  it('querySelectorAll work with query relative href of attrs with $ and complete string', () => {
    const a = document.createElement('a');
    a.setAttribute('href', 'openkraken.com');
    a.text = 'openkraken.com';
    document.body.appendChild(a);

    const path = document.createElement('a');
    path.setAttribute('href', '/path');
    path.text = 'path';
    document.body.appendChild(path);

    expect(document.querySelectorAll('a[href$="/path"]').length).toBe(1);
  });

  it('querySelectorAll work with query relative href', () => {
    const a = document.createElement('a');
    a.setAttribute('href', 'openkraken.com');
    a.text = 'openkraken.com';
    document.body.appendChild(a);

    const path = document.createElement('a');
    path.setAttribute('href', '/path');
    path.text = 'path';
    document.body.appendChild(path);

    expect(document.querySelectorAll('a[href="/path"]').length).toBe(1);
  });



  it('querySelector work with query relative href of attrs with *', () => {
    const a = document.createElement('a');
    a.setAttribute('href', 'openkraken.com');
    a.text = 'openkraken.com';
    document.body.appendChild(a);

    const path = document.createElement('a');
    path.setAttribute('href', '/path');
    path.text = 'path';
    document.body.appendChild(path);

    expect(document.querySelector('a[href*="/path"]')?.getAttribute('href')).toBe('/path');
  });

  it('querySelector work with query relative href of attrs with ^', () => {
    const a = document.createElement('a');
    a.setAttribute('href', 'openkraken.com');
    a.text = 'openkraken.com';
    document.body.appendChild(a);

    const path = document.createElement('a');
    path.setAttribute('href', '/path');
    path.text = 'path';
    document.body.appendChild(path);

    expect(document.querySelector('a[href^="/"]')?.getAttribute('href')).toBe('/path');
  });

  it('querySelector work with query relative href of attrs with ^ and complete string', () => {
    const a = document.createElement('a');
    a.setAttribute('href', 'openkraken.com');
    a.text = 'openkraken.com';
    document.body.appendChild(a);

    const path = document.createElement('a');
    path.setAttribute('href', '/path');
    path.text = 'path';
    document.body.appendChild(path);

    expect(document.querySelector('a[href^="/path"]')?.getAttribute('href')).toBe('/path');
  });

  it('querySelector work with query relative href of attrs with $', () => {
    const a = document.createElement('a');
    a.setAttribute('href', 'openkraken.com');
    a.text = 'openkraken.com';
    document.body.appendChild(a);

    const path = document.createElement('a');
    path.setAttribute('href', '/path');
    path.text = 'path';
    document.body.appendChild(path);

    expect(document.querySelector('a[href$="th"]')?.getAttribute('href')).toBe('/path');
  });

  it('querySelector work with query relative href of attrs with $ and complete string', () => {
    const a = document.createElement('a');
    a.setAttribute('href', 'openkraken.com');
    a.text = 'openkraken.com';
    document.body.appendChild(a);

    const path = document.createElement('a');
    path.setAttribute('href', '/path');
    path.text = 'path';
    document.body.appendChild(path);

    expect(document.querySelector('a[href$="/path"]')?.getAttribute('href')).toBe('/path');
  });

  it('querySelector work with query relative href', () => {
    const a = document.createElement('a');
    a.setAttribute('href', 'openkraken.com');
    a.text = 'openkraken.com';
    document.body.appendChild(a);

    const path = document.createElement('a');
    path.setAttribute('href', '/path');
    path.text = 'path';
    document.body.appendChild(path);

    expect(document.querySelector('a[href="/path"]')?.getAttribute('href')).toBe('/path');
  });

  it('querySelectorAll work with query absolute href of attrs with *', () => {
    const a = document.createElement('a');
    a.setAttribute('href', 'openkraken.com');
    a.text = 'openkraken.com';
    document.body.appendChild(a);

    const path = document.createElement('a');
    path.setAttribute('href', '/path');
    path.text = 'path';
    document.body.appendChild(path);

    expect(document.querySelectorAll('a[href*="openkraken.com"]').length).toBe(1);
  });

  it('querySelectorAll work with query absolute href of attrs with ^', () => {
    const a = document.createElement('a');
    a.setAttribute('href', 'openkraken.com');
    a.text = 'openkraken.com';
    document.body.appendChild(a);

    const path = document.createElement('a');
    path.setAttribute('href', '/path');
    path.text = 'path';
    document.body.appendChild(path);

    expect(document.querySelectorAll('a[href^="open"]').length).toBe(1);
  });

  it('querySelectorAll work with query absolute href of attrs with ^ and complete string', () => {
    const a = document.createElement('a');
    a.setAttribute('href', 'openkraken.com');
    a.text = 'openkraken.com';
    document.body.appendChild(a);

    const path = document.createElement('a');
    path.setAttribute('href', '/path');
    path.text = 'path';
    document.body.appendChild(path);

    expect(document.querySelectorAll('a[href^="openkraken.com"]').length).toBe(1);
  });

  it('querySelectorAll work with query absolute href of attrs with $', () => {
    const a = document.createElement('a');
    a.setAttribute('href', 'openkraken.com');
    a.text = 'openkraken.com';
    document.body.appendChild(a);

    const path = document.createElement('a');
    path.setAttribute('href', '/path');
    path.text = 'path';
    document.body.appendChild(path);

    expect(document.querySelectorAll('a[href$="com"]').length).toBe(1);
  });

  it('querySelectorAll work with query absolute href of attrs with $ and complete string', () => {
    const a = document.createElement('a');
    a.setAttribute('href', 'openkraken.com');
    a.text = 'openkraken.com';
    document.body.appendChild(a);

    const path = document.createElement('a');
    path.setAttribute('href', '/path');
    path.text = 'path';
    document.body.appendChild(path);

    expect(document.querySelectorAll('a[href$="openkraken.com"]').length).toBe(1);
  });

  it('querySelectorAll work with query absolute href', () => {
    const a = document.createElement('a');
    a.setAttribute('href', 'openkraken.com');
    a.text = 'openkraken.com';
    document.body.appendChild(a);

    const path = document.createElement('a');
    path.setAttribute('href', '/path');
    path.text = 'path';
    document.body.appendChild(path);

    expect(document.querySelectorAll('a[href="openkraken.com"]').length).toBe(1);
  });

  it('querySelector work with query absolute href of attrs with *', () => {
    const a = document.createElement('a');
    a.setAttribute('href', 'openkraken.com');
    a.text = 'openkraken.com';
    document.body.appendChild(a);

    const path = document.createElement('a');
    path.setAttribute('href', '/path');
    path.text = 'path';
    document.body.appendChild(path);

    expect(document.querySelector('a[href*="openkraken.com"]')?.getAttribute('href')).toBe('openkraken.com');
  });

  it('querySelector work with query absolute href of attrs with ^', () => {
    const a = document.createElement('a');
    a.setAttribute('href', 'openkraken.com');
    a.text = 'openkraken.com';
    document.body.appendChild(a);

    const path = document.createElement('a');
    path.setAttribute('href', '/path');
    path.text = 'path';
    document.body.appendChild(path);

    expect(document.querySelector('a[href^="open"]')?.getAttribute('href')).toBe('openkraken.com');
  });

  it('querySelector work with query absolute href of attrs with ^ and complete string', () => {
    const a = document.createElement('a');
    a.setAttribute('href', 'openkraken.com');
    a.text = 'openkraken.com';
    document.body.appendChild(a);

    const path = document.createElement('a');
    path.setAttribute('href', '/path');
    path.text = 'path';
    document.body.appendChild(path);

    expect(document.querySelector('a[href^="openkraken.com"]')?.getAttribute('href')).toBe('openkraken.com');
  });

  it('querySelector work with query absolute href of attrs with $', () => {
    const a = document.createElement('a');
    a.setAttribute('href', 'openkraken.com');
    a.text = 'openkraken.com';
    document.body.appendChild(a);

    const path = document.createElement('a');
    path.setAttribute('href', '/path');
    path.text = 'path';
    document.body.appendChild(path);

    expect(document.querySelector('a[href$="com"]')?.getAttribute('href')).toBe('openkraken.com');
  });

  it('querySelector work with query absolute href of attrs with $ and complete string', () => {
    const a = document.createElement('a');
    a.setAttribute('href', 'openkraken.com');
    a.text = 'openkraken.com';
    document.body.appendChild(a);

    const path = document.createElement('a');
    path.setAttribute('href', '/path');
    path.text = 'path';
    document.body.appendChild(path);

    expect(document.querySelector('a[href$="openkraken.com"]')?.getAttribute('href')).toBe('openkraken.com');
  });

  it('querySelector work with query absolute href', () => {
    const a = document.createElement('a');
    a.setAttribute('href', 'openkraken.com');
    a.text = 'openkraken.com';
    document.body.appendChild(a);

    const path = document.createElement('a');
    path.setAttribute('href', '/path');
    path.text = 'path';
    document.body.appendChild(path);

    expect(document.querySelector('a[href="openkraken.com"]')?.getAttribute('href')).toBe('openkraken.com');
  });
});
