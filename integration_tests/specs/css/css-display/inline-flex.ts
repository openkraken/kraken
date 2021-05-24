describe('Display inline-flex', () => {
  it('should work with basic samples', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      width: '100px',
      height: '100px',
      display: 'inline-flex',
      justifyContent: 'center',
      alignItems: 'center',
      backgroundColor: '#666',
    });
    container.appendChild(document.createTextNode('inline-flex'));

    document.body.appendChild(container);
    document.body.appendChild(
      document.createTextNode(
        'This text should display as the same line as the box'
      )
    );

    await snapshot();
  });
});
