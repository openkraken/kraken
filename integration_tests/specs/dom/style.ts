describe('Element style', function () {
  it('should work with setProperty', async () => {
    let div = document.createElement('div');
    div.style.setProperty('width', '100px');
    div.style.setProperty('height', '100px');
    div.style.background = 'red';

    expect(div.style.getPropertyValue('width')).toBe('100px');
    expect(div.style.getPropertyValue('height')).toBe('100px');

    document.body.appendChild(div);
    await snapshot();
  });

  it('should work with removeProperty', async () => {
    let div = document.createElement('div');
    div.style.setProperty('width', '100px');
    div.style.setProperty('height', '100px');
    div.style.background = 'red';
    document.body.appendChild(div);
    await snapshot();

    expect(div.style.getPropertyValue('width')).toBe('100px');
    expect(div.style.getPropertyValue('height')).toBe('100px');

    div.style.removeProperty('width');
    div.style.removeProperty('height');

    expect(div.style.getPropertyValue('width')).toBe('');
    expect(div.style.getPropertyValue('height')).toBe('');

    div.appendChild(document.createTextNode('1234'));

    await snapshot();

  });
});
