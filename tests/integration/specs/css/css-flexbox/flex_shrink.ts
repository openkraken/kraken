describe('flexbox flex-shrink', () => {
  it('should work when flex-direction is row', async () => {
    const container1 = document.createElement('div');
    setStyle(container1, {
      display: 'flex',
      flexDirection: 'row',
      width: '500rpx',
      height: '100rpx',
      marginBottom: '10rpx',
    });

    document.body.appendChild(container1);

    const child1 = document.createElement('div');
    setStyle(child1, {
      backgroundColor: '#999',
      width: '300rpx',
    });
    child1.appendChild(document.createTextNode('flex-shrink: 1'));
    container1.appendChild(child1);

    const child2 = document.createElement('div');
    setStyle(child2, {
      flexShrink: 2,
      backgroundColor: '#f40',
      width: '200rpx',
    });
    child2.appendChild(document.createTextNode('flex-shrink: 2'));
    container1.appendChild(child2);

    const child3 = document.createElement('div');
    setStyle(child3, {
      flexShrink: 1,
      backgroundColor: 'green',
      width: '200rpx',
    });
    child3.appendChild(document.createTextNode('flex-shrink: 1'));
    container1.appendChild(child3);

    await matchScreenshot();
  });

  it('should work when flex-direction is column', async () => {
    const container2 = document.createElement('div');
    setStyle(container2, {
      display: 'flex',
      flexDirection: 'column',
      width: '500rpx',
      height: '400rpx',
      marginBottom: '10rpx',
    });

    document.body.appendChild(container2);

    const child4 = document.createElement('div');
    setStyle(child4, {
      backgroundColor: '#999',
      height: '300rpx',
    });
    child4.appendChild(document.createTextNode('flex-shrink: 1'));
    container2.appendChild(child4);

    const child5 = document.createElement('div');
    setStyle(child5, {
      flexShrink: 2,
      backgroundColor: '#f40',
      height: '200rpx',
    });
    child5.appendChild(document.createTextNode('flex-shrink: 2'));
    container2.appendChild(child5);

    const child6 = document.createElement('div');
    setStyle(child6, {
      flexShrink: 1,
      backgroundColor: 'green',
      height: '200rpx',
    });
    child6.appendChild(document.createTextNode('flex-shrink: 1'));
    container2.appendChild(child6);

    await matchScreenshot();
  });
});
