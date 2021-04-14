describe('Transform scale3d', () => {
  it('001', async () => {
    document.body.appendChild(
      createElementWithStyle('div', {
        width: '100px',
        height: '100px',
        marginTop: '10px',
        backgroundColor: 'red',
        transform: 'scale3d(0.6, 0.8, 0.3) rotate3d(5deg, 8deg, 3deg)',
      })
    );

    await snapshot();
  });
});
