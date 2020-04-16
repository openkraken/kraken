describe('Subtree Visibility', () => {
  it('should visible', async () => {
    var container1 = document.createElement('div');

    setStyle(container1, {
      subtreeVisibility: 'visible',
      backgroundColor: 'red',
      width: '200px',
      height: '200px',
    });

    document.body.appendChild(container1);

    await matchScreenshot();
  });

  it('should hidden', async () => {
    var container1 = document.createElement('div');

    setStyle(container1, {
      subtreeVisibility: 'hidden',
      backgroundColor: 'red',
      width: '200px',
      height: '200px',
    });

    document.body.appendChild(container1);

    await matchScreenshot();
  });

  it('should auto visible', async () => {
    var container1 = document.createElement('div');

    setStyle(container1, {
      subtreeVisibility: 'hidden',
      backgroundColor: 'red',
      width: '200px',
      height: '200px',
    });

    document.body.appendChild(container1);

    setStyle(container1, {
      subtreeVisibility: 'auto',
    });

    await sleep(0.1);
    await matchScreenshot();
  });

  it('should auto hidden', async () => {
    var container1 = document.createElement('div');

    setStyle(container1, {
      subtreeVisibility: 'auto',
      backgroundColor: 'red',
      width: '200px',
      height: '200px',
    });

    document.body.appendChild(container1);

    setStyle(container1, {
      position: 'absolute',
      top: '-1000px',
    });

    await matchElementImageSnapshot(container1);
  });

});
