/**
 * Test DOM API for
 * - document.createElement
 * - document.createTextNode
 * - document.createComment
 * - document.documentElement
 */
describe('Document api', () => {
  it('should work', async () => {
    const container = document.createElement('div');
    container.appendChild(document.createTextNode('This is a text node.'));
    container.appendChild(document.createComment('This is a comment'));
    document.body.appendChild(container);

    await snapshot();
  });

  it('documentElement', async () => {
    const documentElementWidth = document.documentElement.clientWidth;
    const documentElementHeight = document.documentElement.clientHeight;

    const text1 = document.createTextNode('documentElement width: ' + documentElementWidth + '\n');
    document.body.appendChild(text1);

    const text2 = document.createTextNode('documentElement height: ' + documentElementHeight + '\n');
    document.body.appendChild(text2);

    await snapshot();
  });

  it('document.all', () => {
    expect(document.all).not.toBeUndefined();
    expect(document.all.length).toBeGreaterThan(0);
  });

  it('document querySelector cant find element', () => {
    ['red','black','green','yellow','blue'].forEach((item, index) => {
      const div = document.createElement('div')
      div.style.width = '100px';
      div.style.height = '100px';
      div.style.backgroundColor = item;
      div.setAttribute('id', `id-${index}`);
      document.body.appendChild(div);
    })
    
    expect(document.querySelector('span')).toBeNull();
  })

  it('document querySelector find first element', () => {
    ['red','black','green','yellow','blue'].forEach((item, index) => {
      const div = document.createElement('div')
      div.style.width = '100px';
      div.style.height = '100px';
      div.style.backgroundColor = item;
      div.setAttribute('id', `id-${index}`);
      document.body.appendChild(div);
    })
    
    const ele = document.querySelector('div');
    expect(ele?.getAttribute('id')).toBe('id-0');
  })

  it('document querySelectorAll length of elements', () => {
    const szEle = ['red','black','green','yellow','blue'];
    szEle.forEach((item, index) => {
      const div = document.createElement('div')
      div.style.width = '100px';
      div.style.height = '100px';
      div.style.backgroundColor = item;
      div.setAttribute('id', `id-${index}`);
      document.body.appendChild(div);
    })
    
    const eles = document.querySelectorAll('div');
    expect(eles.length).toBe(szEle.length);
  })

  it('document querySelectorAll first element', () => {
    const szEle = ['red','black','green','yellow','blue'];
    szEle.forEach((item, index) => {
      const div = document.createElement('div')
      div.style.width = '100px';
      div.style.height = '100px';
      div.style.backgroundColor = item;
      div.setAttribute('id', `id-${index}`);
      document.body.appendChild(div);
    })
    
    const eles = document.querySelectorAll('div');
    expect(eles[0].getAttribute('id')).toBe('id-0');
  })

  it('document querySelectorAll cant find element by tag name', () => {
    ['red','black','green','yellow','blue'].forEach((item, index) => {
      const div = document.createElement('div')
      div.style.width = '100px';
      div.style.height = '100px';
      div.style.backgroundColor = item;
      div.setAttribute('id', `id-${index}`);
      document.body.appendChild(div);
    })
    
    expect(document.querySelectorAll('span').length).toBe(0);
  })

  it('document querySelector find element by id', () => {
    ['red','black','green','yellow','blue'].forEach((item, index) => {
      const div = document.createElement('div')
      div.style.width = '100px';
      div.style.height = '100px';
      div.style.backgroundColor = item;
      div.setAttribute('id', `id-${index}`);
      document.body.appendChild(div);
    })
    
    expect(document.querySelector('#id-1')?.style.backgroundColor).toBe('black');
  })

  it('document querySelector find element by className', () => {
    ['red','black','green','yellow','blue'].forEach((item, index) => {
      const div = document.createElement('div')
      div.style.width = '100px';
      div.style.height = '100px';
      div.style.backgroundColor = item;
      div.setAttribute('id', `id-${index}`);
      div.className = `class-${index} cc`;
      document.body.appendChild(div);
    })
    
    expect(document.querySelector('.class-2')?.style.backgroundColor).toBe('green');
  })

  it('document querySelector find element by classNames', () => {
    ['red','black','green','yellow','blue'].forEach((item, index) => {
      const div = document.createElement('div')
      div.style.width = '100px';
      div.style.height = '100px';
      div.style.backgroundColor = item;
      div.setAttribute('id', `id-${index}`);
      div.className = `class-${index} cc`;
      document.body.appendChild(div);
    })
    
    expect(document.querySelector('.class-2 cc')?.style.backgroundColor).toBe('green');
  })

  it('document querySelectorAll find all element', () => {
    ['red','black','green','yellow','blue'].forEach((item, index) => {
      const div = document.createElement('div')
      div.style.width = '100px';
      div.style.height = '100px';
      div.style.backgroundColor = item;
      div.setAttribute('id', `id-${index}`);
      div.className = `class-${index} cc`;
      document.body.appendChild(div);
    })
    
    expect(document.querySelectorAll('*').length).toBe(8);
  })
});
