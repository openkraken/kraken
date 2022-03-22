describe('Transition property', () => {
  it('backgroundColor', async (done) => {
    const container1 = document.createElement('div');
    document.body.appendChild(container1);
    setElementStyle(container1, {
      position: 'absolute',
      padding: '30px',
      transition: 'all 1s linear',
    }); 
    container1.appendChild(document.createTextNode('DIV'));
    await snapshot();

    requestAnimationFrame(() => {
      setElementStyle(container1, {
        backgroundColor: 'red',
      });

      // Wait for animation finished.
      setTimeout(async () => {
        await snapshot();
        done();
      }, 1100);
    });
  });

});
