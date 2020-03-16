describe('snapshotTest', () => {
  it('helloworld', async () => {
    function setStyle(dom: any, object: any) {
      for (let key in object) {
        if (object.hasOwnProperty(key)) {
          dom.style[key] = object[key];
        }
      }
    }

    const container1 = document.createElement('div');
    setStyle(container1, {
      padding: '20rpx', backgroundColor: '#999', margin: '40rpx', border: '5px solid #000'
    });
    document.body.appendChild(container1);
    await expectAsync(container1.toBlob()).toMatchImageSnapshot('container1');
    await expectAsync(container1.toBlob()).toMatchImageSnapshot('body');
  });
});