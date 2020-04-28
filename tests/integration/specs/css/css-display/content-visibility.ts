describe('Content Visibility', () => {
  it('should visible', async () => {
    var container1 = document.createElement('div');

    setElementStyle(container1, {
      contentVisibility: 'visible',
      backgroundColor: 'red',
      width: '200px',
      height: '200px',
    });

    document.body.appendChild(container1);

    await matchScreenshot();
  });

  it('should hidden', async () => {
    var container1 = document.createElement('div');

    setElementStyle(container1, {
      contentVisibility: 'hidden',
      backgroundColor: 'red',
      width: '200px',
      height: '200px',
    });

    document.body.appendChild(container1);

    await matchScreenshot();
  });

  it('should auto visible', async () => {
    var container1 = document.createElement('div');

    setElementStyle(container1, {
      contentVisibility: 'hidden',
      backgroundColor: 'red',
      width: '200px',
      height: '200px',
    });

    document.body.appendChild(container1);

    setElementStyle(container1, {
      contentVisibility: 'auto',
    });

    await sleep(0.1);
    await matchScreenshot();
  });

  it('should auto hidden', async () => {
    var container1 = document.createElement('div');

    setElementStyle(container1, {
      contentVisibility: 'auto',
      backgroundColor: 'red',
      width: '200px',
      height: '200px',
    });

    document.body.appendChild(container1);

    setElementStyle(container1, {
      position: 'absolute',
      top: '-1000px',
    });

    // Should be empty blob
    const blob = await container1.toBlob(1.0);
    expect(blob.size).toEqual(0);
  });

});
