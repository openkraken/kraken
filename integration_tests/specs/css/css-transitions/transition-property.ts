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

    container1.addEventListener('transitionend', async () => {
      await snapshot();
      done();
    });

    requestAnimationFrame(() => {
      setElementStyle(container1, {
        backgroundColor: 'red',
      });
    });
  });

});
