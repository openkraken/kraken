describe('Display', () => {
  it('should work with none', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      width: '100px',
      height: '100px',
      display: 'none',
      backgroundColor: '#666',
    });

    document.body.appendChild(container);
    document.body.appendChild(
      document.createTextNode('The box should not display.')
    );

    await snapshot();
  });
});
