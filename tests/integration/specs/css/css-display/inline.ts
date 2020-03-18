describe('Display inline', () => {
  it('should work with basic samples', async () => {
    const container = document.createElement('div');
    setStyle(container, {
      width: '100px',
      height: '100px',
      display: 'inline',
      backgroundColor: '#666',
    });
    container.appendChild(document.createTextNode('This box has no width and height'));

    document.body.appendChild(container);
    document.body.appendChild(document.createTextNode('This text should display as the same line as the box'));

    await matchScreenshot();
  });
});
