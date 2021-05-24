describe('Transform skew', function() {
  it('001', async () => {
    document.body.appendChild(
      createElementWithStyle('div', {
        width: '100px',
        height: '100px',
        marginTop: '10px',
        backgroundColor: 'red',
        transform: 'skew(-5deg)',
      })
    );

    await snapshot();
  });
});
