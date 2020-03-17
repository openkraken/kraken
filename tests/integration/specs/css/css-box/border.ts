describe('box', () => {
  it('should work with border', async () => {
    const div = document.createElement('div');
    setStyle(div, {
      width: '100px',
      height: '100px',
      backgroundColor: '#666',
      border: '2px solid #f40',
    });

    document.body.appendChild(div);
    div.style.border = '4px solid blue';
    await expectAsync(document.body.toBlob(1)).toMatchImageSnapshot();
  });
});
