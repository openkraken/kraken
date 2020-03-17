describe('display', () => {
  it('should work with block', async () => {

    const container = document.createElement('div');
    setStyle(container, {
      width: '100px',
      height: '100px',
      display: 'block',
      backgroundColor: '#666',
    });
    container.appendChild(document.createTextNode('block'));

    document.body.appendChild(container);
    document.body.appendChild(document.createTextNode('This text should wrap into next line from the box.'));

    await expectAsync(document.body.toBlob(1)).toMatchImageSnapshot();
  });
});
