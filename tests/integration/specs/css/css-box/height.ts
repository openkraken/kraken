describe('Box height', () => {
  it('should work with basic samples', async () => {
    const div = document.createElement('div');
    setStyle(div, {
      width: '100px',
      height: '100px',
      backgroundColor: '#666',
    });

    document.body.appendChild(div);
    div.style.height = '200px';
    await matchScreenshot();
  });
});
