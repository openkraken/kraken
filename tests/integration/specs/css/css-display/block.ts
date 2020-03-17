describe('Display block', () => {
  it('should work with basic samples', async () => {
    const container = document.createElement('div');
    setStyle(container, {
      width: '100px',
      height: '100px',
      display: 'block',
      backgroundColor: '#666',
    });

    document.body.appendChild(container);
    document.body.appendChild(document.createTextNode('This text should wrap into next line from the box.'));

    await expectAsync(document.body.toBlob(1)).toMatchImageSnapshot();
  });
});
