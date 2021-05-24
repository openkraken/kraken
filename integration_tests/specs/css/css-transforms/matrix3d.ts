describe('Transform matrix3d', function() {
  it('001', async () => {
    document.body.appendChild(
      createElementWithStyle('div', {
        width: '100px',
        height: '100px',
        marginTop: '10px',
        backgroundColor: 'red',
        transform: 'matrix3d(0,1,1,1,10,10,1,0,0,1,1,1,1,1,0)',
      })
    );

    await snapshot();
  });
});
