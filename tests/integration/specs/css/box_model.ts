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

  it('should work with height', async () => {
    const div = document.createElement('div');
    setStyle(div, {
      width: '100px',
      height: '100px',
      backgroundColor: '#666',
    });

    document.body.appendChild(div);
    div.style.height = '200px';
    await expectAsync(div.toBlob(1.0)).toMatchImageSnapshot();
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
    const div = document.createElement('div');
    setStyle(div, {
      width: '100px',
      height: '100px',
      backgroundColor: '#666',
      margin: 0,
    });

    document.body.appendChild(div);
    div.style.margin = '20px';
    await expectAsync(document.body.toBlob(1.0)).toMatchImageSnapshot();
  });

  it('should work with padding', async () => {
    const container1 = document.createElement('div');
    setStyle(container1, {
      width: '100px',
      height: '100px',
      backgroundColor: '#666',
      padding: 0,
    });

    document.body.appendChild(container1);

    const container2 = document.createElement('div');
    setStyle(container2, {
      width: '50px',
      height: '50px',
      backgroundColor: '#f40',
    });

    container1.appendChild(container2);
    container1.style.padding = '20px';

    await expectAsync(document.body.toBlob(1.0)).toMatchImageSnapshot();
  });

  it('should work with width', async () => {
    const div = document.createElement('div');
    setStyle(div, {
      width: '100px',
      height: '100px',
      backgroundColor: '#666',
    });

    document.body.appendChild(div);
    div.style.width = '200px';
    await expectAsync(document.body.toBlob(1.0)).toMatchImageSnapshot();
  });

  it('should work with position', async () => {
    var container = document.createElement('div');
    var div1 = document.createElement('div');
    var div2 = document.createElement('span');

    container.appendChild(div1);
    container.appendChild(div2);
    document.body.appendChild(container);

    container.style.width = '300px';
    container.style.height = '800px';
    container.style.backgroundColor = '#999';

    div1.style.position = 'absolute';
    div1.style.width = '100px';
    div1.style.height = '200px';
    div1.style.backgroundColor = 'red';

    div2.style.position = 'absolute';
    div2.style.width = '100px';
    div2.style.height = '100px';
    div2.style.top = '50px';
    div2.style.backgroundColor = 'green';

    container.style.marginLeft = '50px';
    container.style.position = 'relative';
    container.style.top = '100px';

    await expectAsync(document.body.toBlob(1.0)).toMatchImageSnapshot();
  });
});
