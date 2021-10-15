describe('innerHTML', () => {
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

    expect(document.body.innerHTML).toEqual('<div style="height: 100px;width: 100px;"></div>');
  });

  it('should work width attribute when get property', async () => {
    const div = document.createElement('div');
    div.setAttribute('attr-key', 'attr-value');

    document.body.appendChild(div);

    expect(document.body.innerHTML).toEqual('<div attr-key="attr-value" ></div>');
  });

  it('should work width attribute when get property', async () => {
    const div = document.createElement('div');
    div.setAttribute('attr-key', 'attr-value');

    document.body.appendChild(div);

    expect(document.body.innerHTML).toEqual('<div attr-key="attr-value" ></div>');
  });

  it('set empty string should remove all children', async () => {
    const div = document.createElement('div');
    document.body.appendChild(div);
    document.body.innerHTML = '';

    expect(document.body.children.length).toEqual(0);
  })

});
