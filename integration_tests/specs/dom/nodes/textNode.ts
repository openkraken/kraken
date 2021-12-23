describe('TextNode', () => {
  it('should work with basic example', async () => {
    const div = document.createElement('div');
    const text = document.createTextNode('before modified');

    document.body.appendChild(div);
    div.appendChild(text);

    await snapshot();
  });

  it('should work with text update', async () => {
    const div = document.createElement('div');
    const text = document.createTextNode('before modified');

    document.body.appendChild(div);
    div.appendChild(text);

    text.data = 'after modified';

    await snapshot();
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

    await snapshot();
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

    await snapshot();
  });

  it('the previous sibling is block, the left space of this textnode is hidden', async () => {
    const div = document.createElement('div');
    div.appendChild(document.createTextNode('text1'));
    document.body.appendChild(div);

    const text = document.createTextNode(' text2');
    document.body.appendChild(text);

    await snapshot();
  });

  it('the next sibling is block, the right space of this textnode is hidden', async () => {
    const text = document.createTextNode('text1 ');
    document.body.appendChild(text);

    const div = document.createElement('div');
    div.appendChild(document.createTextNode('text2'));
    document.body.appendChild(div);

    await snapshot();
  });

  it('should work with set textContent', async () => {
    const div = document.createElement('div');
    const text = document.createTextNode('before modified');

    document.body.appendChild(div);
    div.appendChild(text);

    text.textContent = 'after modified';

    await snapshot();
  });

  it('empty string of textNode set data should work', async () => {
    const text = document.createTextNode('');
    document.body.appendChild(text);
    text.data = 'aaa';

    await snapshot();
  });

  it('empty string of textNode should not attach the render object to parent.', async () => {
    const container = document.createElement('div');
    container.style.display = 'flex';
    container.style.justifyContent = 'space-between';
    container.style.alignItems = 'center';

    document.body.appendChild(container);

    container.appendChild(document.createTextNode(''));

    for (let i = 0; i < 3; i++) {
      const child = document.createElement('div');
      child.style.border = '1px solid red';
      child.textContent = `${i}`;
      container.appendChild(child);
    }

    container.appendChild(document.createTextNode(''));

    await snapshot();
  });

  it('createTextNode should not has height when the text is a empty string', async () => {
    const child = document.createElement('div');
    child.style.width = '10px';
    child.style.height = '10px';
    child.style.backgroundColor = 'blue';
    document.body.appendChild(child);
    const text = document.createTextNode("")
    document.body.appendChild(text);

    const child2 = document.createElement('div');
    child2.style.width = '10px';
    child2.style.height = '10px';
    child2.style.backgroundColor = 'red';
    document.body.appendChild(child2);

    await snapshot();
  });

  it('createTextNode should not has height when the text is a empty string and flex layout', async () => {
    const div = document.createElement('div');
    div.style.display = 'flex';

    document.body.appendChild(div);

    const child = document.createElement('div');
    child.style.width = '10px';
    child.style.height = '10px';
    child.style.backgroundColor = 'blue';
    div.appendChild(child);
    const text = document.createTextNode("")
    div.appendChild(text);


    const child2 = document.createElement('div');
    child2.style.width = '10px';
    child2.style.height = '10px';
    child2.style.backgroundColor = 'red';
    div.appendChild(child2);

    await snapshot();
  });

  describe('nodeValue', () => {
    it('assign nodeValue to update.', async () => {
      const text = document.createTextNode('');
      document.body.appendChild(text);

      const TEXT = 'HELLO WORLD!';
      text.nodeValue = TEXT;
      await snapshot();
      expect(text.nodeValue).toEqual(TEXT);
    });
  });
});
