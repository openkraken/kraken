describe('Display flex', () => {
  it('001', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      width: '100px',
      height: '100px',
      display: 'flex',
      justifyContent: 'center',
      alignItems: 'center',
      backgroundColor: '#666',
    });
    container.appendChild(document.createTextNode('inline-flex'));

    document.body.appendChild(container);
    document.body.appendChild(
      document.createTextNode(
        'This text should display as the next line as the box'
      )
    );
    await snapshot();
  });

  it('002', async () => {
    var container = document.createElement('div');
    container.style.display = 'flex';
    container.style.width = '300px';
    container.style.height = '300px';
    container.style.backgroundColor = 'red';

    document.body.appendChild(container);
    await snapshot();
  });
});
