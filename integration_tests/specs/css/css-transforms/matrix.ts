describe('Transform matrix', () => {
  it('001', async function() {
    document.body.appendChild(
      createElementWithStyle('div', {
        width: '100px',
        height: '100px',
        backgroundColor: 'red',
        transform: 'matrix(0,1,1,1,10,10)',
      })
    );

    await snapshot();
  });
});
