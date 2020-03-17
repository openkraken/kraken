describe('box', () => {
  it('should work with height', async () => {
    const div = document.createElement('div');
    setStyle(div, {
      width: '100px',
      height: '100px',
      backgroundColor: '#666',
    });

    document.body.appendChild(div);
    div.style.height = '200px';
    await expectAsync(document.body.toBlob(1)).toMatchImageSnapshot('');
  });
});
