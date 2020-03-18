describe('Height', () => {
  it('001', async () => {
    const div = document.createElement('div');
    setStyle(div, {
      width: '100px',
      height: '100px',
      backgroundColor: '#666',
    });

    document.body.appendChild(div);
    div.style.height = '200px';
    await expectAsync(div.toBlob(1)).toMatchImageSnapshot('');
  });
});
