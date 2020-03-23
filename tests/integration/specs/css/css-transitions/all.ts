// @TODO: enable transition while it is fixed.
describe('Transition all', () => {
  it('001', (done) => {
    const container1 = document.createElement('div');
    document.body.appendChild(container1);
    setStyle(container1, {
      position: 'absolute',
      top: '100px',
      left: 0,
      padding: '20px',
      backgroundColor: '#999',
      transition: 'all 1s ease-out',
    });
    container1.appendChild(document.createTextNode('DIV 1'));

    requestAnimationFrame(() => {
      setStyle(container1, {
        top: 0,
      });

      // Wait for animation finished.
      setTimeout(async () => {
        await matchScreenshot();
        done();
      }, 1100);
    });
  });
});
