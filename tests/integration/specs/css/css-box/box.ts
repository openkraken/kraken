describe('Box', () => {
  it('should work with basic samples', async () => {
    const container1 = document.createElement('div');
    setStyle(container1, {
      padding: '20rpx',
      backgroundColor: '#999',
      margin: '40rpx',
      border: '5px solid #000',
    });

    const container2 = document.createElement('div');
    setStyle(container2, {
      padding: '20rpx',
      backgroundColor: '#666',
      margin: '40rpx',
      border: '5px solid #000',
    });

    const container3 = document.createElement('div');
    setStyle(container3, {
      padding: '20rpx',
      height: '100rpx',
      backgroundColor: '#f40',
      margin: '40rpx',
      border: '5px solid #000',
    });

    const textNode = document.createTextNode('Hello World');
    document.body.appendChild(container1);
    container1.appendChild(container2);
    container2.appendChild(container3);
    container3.appendChild(textNode);

    await expectAsync(document.body.toBlob(1.0)).toMatchImageSnapshot();
  });
});