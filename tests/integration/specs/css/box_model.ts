describe('BoxModel', () => {
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

  it('should work with border', async () => {
    const div = document.createElement('div');
    setStyle(div, {
      width: '100px',
      height: '100px',
      backgroundColor: '#666',
      border: '2px solid #f40',
    });

    document.body.appendChild(div);
    div.style.border = '4px solid blue';
    await expectAsync(document.body.toBlob(1.0)).toMatchImageSnapshot();
  });



  it('should work with block_nesting', async () => {
    var container = document.createElement('div');
    container.style.width = '300px';
    container.style.height = '300px';
    container.style.backgroundColor = 'red';

    var box = document.createElement('div');
    box.style.width = '150px';
    box.style.height = '150px';
    box.style.backgroundColor = 'green';

    container.appendChild(box);
    document.body.appendChild(container);
    await expectAsync(document.body.toBlob(1.0)).toMatchImageSnapshot();
  });

  it('should work with margin', async () => {

  });

  it('should work with padding', async () => {

  });
});
