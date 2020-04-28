describe('flexbox flex-grow', () => {
  it('should work when flex-direction is row', async () => {
    const container1 = document.createElement('div');
    setElementStyle(container1, {
      display: 'flex',
      flexDirection: 'row',
      width: '500rpx',
      height: '100rpx',
      marginBottom: '10rpx',
    });

    document.body.appendChild(container1);

    const child1 = document.createElement('div');
    setElementStyle(child1, {
      backgroundColor: '#999',
    });
    child1.appendChild(document.createTextNode('flex-grow: 0'));
    container1.appendChild(child1);

    const child2 = document.createElement('div');
    setElementStyle(child2, {
      flexGrow: 2,
      backgroundColor: '#f40',
    });
    child2.appendChild(document.createTextNode('flex-grow: 2'));
    container1.appendChild(child2);

    const child3 = document.createElement('div');
    setElementStyle(child3, {
      flexGrow: 1,
      backgroundColor: 'green',
    });
    child3.appendChild(document.createTextNode('flex-grow: 1'));
    container1.appendChild(child3);

    await matchScreenshot();
  });

  it('should work when flex-direction is column', async () => {
    const container2 = document.createElement('div');
    setElementStyle(container2, {
      display: 'flex',
      flexDirection: 'column',
      width: '500rpx',
      height: '200rpx',
      marginBottom: '10rpx',
    });

    document.body.appendChild(container2);

    const child4 = document.createElement('div');
    setElementStyle(child4, {
      backgroundColor: '#999',
    });
    child4.appendChild(document.createTextNode('flex-grow: 0'));
    container2.appendChild(child4);

    const child5 = document.createElement('div');
    setElementStyle(child5, {
      flexGrow: 2,
      backgroundColor: '#f40',
    });
    child5.appendChild(document.createTextNode('flex-grow: 2'));
    container2.appendChild(child5);

    const child6 = document.createElement('div');
    setElementStyle(child6, {
      flexGrow: 1,
      backgroundColor: 'green',
    });
    child6.appendChild(document.createTextNode('flex-grow: 1'));
    container2.appendChild(child6);

    await matchScreenshot();
  });
});
