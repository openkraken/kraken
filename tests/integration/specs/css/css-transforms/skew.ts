describe('Transform skew', function() {
  it('001', async () => {
    document.body.appendChild(
      create('div', {
        width: '100px',
        height: '100px',
        marginTop: '10px',
        backgroundColor: 'red',
        transform: 'skew(-5deg)',
      })
    );

    await matchScreenshot();
  });
});
