describe('Box margin', () => {
  it('001', async () => {
    const div = document.createElement('div');
    setStyle(div, {
      width: '100px',
      height: '100px',
      backgroundColor: '#666',
      margin: 0,
    });

    document.body.appendChild(div);
    div.style.margin = '20px';
    await expectAsync(document.body.toBlob(1)).toMatchImageSnapshot('');
  });
});
