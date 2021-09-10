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
    expect(ele?.id).toBe('id-0');
  })
});
