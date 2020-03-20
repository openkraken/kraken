describe('Position relative', () => {
  it('001', async () => {
    const div1 = document.createElement('div');
    setStyle(div1, {
      width: '100px',
      height: '100px',
      backgroundColor: '#666',
      position: 'relative',
      top: '50px',
      left: '50px',
    });
    div1.appendChild(document.createTextNode('relative top & left'));
    document.body.appendChild(div1);

    const div2 = document.createElement('div');
    setStyle(div2, {
      width: '100px',
      height: '100px',
      backgroundColor: '#999',
      position: 'relative',
      bottom: '-50px',
      right: '-50px',
    });
    div2.appendChild(document.createTextNode('relative bottom & right'));
    document.body.appendChild(div2);

    await matchScreenshot();
  });

  xit('should be a green square below', async (done) => {
    let parent = create('div', {
      width: '150px',
      height: '150px',
      backgroundColor: 'green'
    });
    let child = create('div', {
      width: '150px',
      height: '150px',
      backgroundColor: 'white',
      position: 'relative'
    });
    append(parent, child);
    append(BODY, parent);
    await matchElementImageSnapshot(parent);

    requestAnimationFrame(async () => {
      child.style.left = '150px';
      await matchElementImageSnapshot(parent);
      done();
    });
  });
});
