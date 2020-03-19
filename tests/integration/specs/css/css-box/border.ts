describe('Box border', () => {
  it('should work with basic samples', async () => {
    const div = document.createElement('div');
    setStyle(div, {
      width: '100px',
      height: '100px',
      backgroundColor: '#666',
      border: '2px solid #f40',
    });

    document.body.appendChild(div);
    div.style.border = '4px solid blue';
    await matchScreenshot();
  });

  xit('dashed border', async () => {
    const div = create('div', {
      width: '100px',
      height: '100px',
      border: '2px dashed red'
    });
    append(BODY, div);
    await matchScreenshot(div);
  });

  xit('dashed with backgroundColor', async () => {
    const div = create('div', {
      width: '100px',
      height: '100px',
      border: '10px dashed red',
      backgroundColor: 'green'
    });
    append(BODY, div);
    await matchScreenshot(div);
  });

  xit('border-bottom-left-radius', async () => {
    let div = create('div', {
      width: '100px',
      height: '100px',
      'border-bottom-left-radius': '100px',
      backgroundColor: 'red'
    });
    append(BODY, div);
    await matchScreenshot(div);
  });

  xit('border-bottom-right-radius', async () => {
    let div = create('div', {
      width: '100px',
      height: '100px',
      'border-bottom-right-radius': '100px',
      backgroundColor: 'red'
    });
    append(BODY, div);
    await matchScreenshot(div);
  });

  xit('border-top-left-radius', async () => {
    let div = create('div', {
      width: '100px',
      height: '100px',
      'border-top-left-radius': '100px',
      backgroundColor: 'red'
    });
    append(BODY, div);
    await matchScreenshot(div);
  });

  xit('border-top-right-radius', async () => {
    let div = create('div', {
      width: '100px',
      height: '100px',
      'border-top-right-radius': '100px',
      backgroundColor: 'red'
    });
    append(BODY, div);
    await matchScreenshot(div);
  });
});
