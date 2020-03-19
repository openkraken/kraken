fdescribe('Background-color', async () => {
  it('red', async () => {
    const div = document.createElement('div');
    setStyle(div, {
      width: '200px',
      height: '200px',
      backgroundColor: 'red',
    });

    document.body.appendChild(div);
    await expectAsync(div.toBlob(1.0)).toMatchImageSnapshot();
  });
});