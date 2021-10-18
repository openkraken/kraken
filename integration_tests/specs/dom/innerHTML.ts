describe('outerHTML', () => {
  it('should work width element when get property', async () => {
    const div = document.createElement('div');
    div.innerHTML = "<div style=\"background-color: red;width:100px;height: 100px\"></div>";
    document.body.appendChild(div);

    await snapshot();
  });

  it('should work width text node when get property', async () => {
    const div = document.createElement('div');
    div.innerHTML = "<div style=\"color: red\">text</div>";
    document.body.appendChild(div);

    await snapshot();
  });

  it('should work width style when get property', async () => {
    const div = document.createElement('div');
    div.style.width = '100px';
    div.style.height = '100px';

    document.body.appendChild(div);

    expect(div.outerHTML).toEqual('<div style="height: 100px;width: 100px;"></div>');
    expect(div.innerHTML).toBe('');
    expect(document.body.innerHTML).toEqual('<div style="height: 100px;width: 100px;"></div>');
  });

  it('should work width attribute when get property', async () => {
    const div = document.createElement('div');
    div.setAttribute('attr-key', 'attr-value');

    document.body.appendChild(div);

    expect(div.outerHTML).toEqual('<div attr-key="attr-value"></div>');
    expect(div.innerHTML).toBe('');
    expect(document.body.innerHTML).toEqual('<div attr-key="attr-value"></div>');
  });

  it('should work width attribute when get property', async () => {
    const div = document.createElement('div');
    div.setAttribute('attr-key', 'attr-value');

    document.body.appendChild(div);
    expect(div.outerHTML).toEqual('<div attr-key="attr-value"></div>');
    expect(div.innerHTML).toEqual('');
  });
});

describe('innerHTML', () => {
  it('should work width style when get property', async () => {
    const div = document.createElement('div');
    div.style.width = '100px';
    div.style.height = '100px';

    let child = document.createElement('p');
    child.appendChild(document.createTextNode('helloworld'));
    div.appendChild(child);

    document.body.appendChild(div);

    expect(div.innerHTML).toBe('<p>helloworld</p>');
    expect(document.body.innerHTML).toEqual('<div style="height: 100px;width: 100px;"><p>helloworld</p></div>');
  });

  it('set empty string should remove all children', async () => {
    const div = document.createElement('div');
    document.body.appendChild(div);

    div.appendChild(document.createTextNode('1234'));
    div.appendChild(document.createElement('p'));
    document.body.innerHTML = '';

    expect(document.body.children.length).toEqual(0);
  })
});
