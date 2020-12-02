describe('TextNode', () => {
  it('should work with basic example', async () => {
    const div = document.createElement('div');
    const text = document.createTextNode('before modified');

    document.body.appendChild(div);
    div.appendChild(text);

    await matchViewportSnapshot();
  });

  it('should work with text update', async () => {
    const div = document.createElement('div');
    const text = document.createTextNode('before modified');

    document.body.appendChild(div);
    div.appendChild(text);

    text.data = 'after modified';

    await matchViewportSnapshot();
  });

  it('should work with style update of non empty text', async () => {
    const div = document.createElement('div');
    const child = document.createElement('div');
    setElementStyle(child, {
      backgroundColor: '#f40',
      width: '100px',
      height: '100px',
    });
    const text = document.createTextNode('Hello world');
    div.appendChild(child);
    div.appendChild(text);
    div.style.color = 'blue';
    document.body.appendChild(div);

    await matchViewportSnapshot();
  });

  it('should work with style update of empty text', async () => {
    const div = document.createElement('div');
    const child = document.createElement('div');
    setElementStyle(child, {
      backgroundColor: '#f40',
      width: '100px',
      height: '100px',
    });
    const text = document.createTextNode('');
    div.appendChild(child);
    div.appendChild(text);
    div.style.color = 'blue';
    document.body.appendChild(div);

    await matchViewportSnapshot();
  });

  it('should work with set textContent', async () => {
    const div = document.createElement('div');
    const text = document.createTextNode('before modified');

    document.body.appendChild(div);
    div.appendChild(text);

    text.textContent = 'after modified';

    await matchViewportSnapshot();
  });
});
