describe('Transform rotate', function() {
  it('001', async () => {
    document.body.appendChild(
      createElementWithStyle('div', {
        width: '100px',
        height: '100px',
        backgroundColor: 'red',
        transform: 'rotate(5deg)',
      })
    );

    await snapshot();
  });
});
