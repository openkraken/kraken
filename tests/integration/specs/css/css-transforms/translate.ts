describe('Transform translate', () => {
  it('001', async () => {
    document.body.appendChild(
      createElement('div', {
        width: '100px',
        height: '100px',
        backgroundColor: 'red',
        transform: 'translate(10px, 6px )',
      })
    );

    await matchScreenshot();
  });
});
