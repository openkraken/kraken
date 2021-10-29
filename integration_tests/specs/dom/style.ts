describe('Element style', function () {
  it('should work with setProperty', async () => {
    let div = document.createElement('div');
    div.style.setProperty('width', '100px');
    div.style.setProperty('height', '100px');
    div.style.background = 'red';

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

    div.style.removeProperty('width');
    div.style.removeProperty('height');

    div.appendChild(document.createTextNode('1234'));

    await snapshot();

  });
});
