describe('Transform scale&rotate', () => {
  it('001', async () => {
    document.body.appendChild(
      createElementWithStyle('div', {
        width: '100px',
        height: '100px',
        marginTop: '10px',
        backgroundColor: 'red',
        transform: 'scale(1.5) rotate(45deg)',
      })
    );

    await snapshot();
  });
});
