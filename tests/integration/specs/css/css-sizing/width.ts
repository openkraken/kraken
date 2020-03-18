describe('Width', function() {
  it('001', async () => {
    const div = document.createElement('div');
    setStyle(div, {
      width: '100px',
      height: '100px',
      backgroundColor: '#666',
    });

    document.body.appendChild(div);
    div.style.width = '200px';
    await matchScreenshot();
  });
});
