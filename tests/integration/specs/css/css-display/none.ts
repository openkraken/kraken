describe('Display none', () => {
  it('should work with basic samples', async () => {

    const container = document.createElement('div');
    setStyle(container, {
      width: '100px',
      height: '100px',
      display: 'none',
      backgroundColor: '#666',
    });

    document.body.appendChild(container);
    document.body.appendChild(document.createTextNode('The box should not display.'));

    await expectAsync(document.body.toBlob(1)).toMatchImageSnapshot();
  });
});
