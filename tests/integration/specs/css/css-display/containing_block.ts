describe('Containing block for', () => {
  it('relative positioned elements near block-level ancestor', async () => {
    var p = document.createElement('p');
    document.body.appendChild(p);
    p.appendChild(document.createTextNode('Test passes if there is a filled green square and no red.'));

    var div1 = document.createElement('div');
    setStyle(div1, {
      backgroundColor: 'red',
      display: 'block',
      height: '100px',
      width: '100px',
    });
    document.body.appendChild(div1);

    var div2 = document.createElement('div');
    setStyle(div2, {
      backgroundColor: 'green',
      width: '100px',
      height: '100px',
      position: 'relative',
    });
    div1.appendChild(div2);

    await matchScreenshot();
  });

  it('relative positioned elements near inline-block ancestor', async () => {
    var p = document.createElement('p');
    document.body.appendChild(p);
    p.appendChild(document.createTextNode('Test passes if there is a filled green square and no red.'));

    var div1 = document.createElement('div');
    setStyle(div1, {
      background: 'red',
      display: 'inline-block',
      height: '60px',
      padding: '20px',
      width: '60px',
    });
    document.body.appendChild(div1);

    var div2 = document.createElement('div');
    setStyle(div2, {
      background: 'green',
      height: '100px',
      left: '-20px',
      position: 'relative',
      top: '-20px',
      width: '100px',
    });
    div1.appendChild(div2);

    await matchScreenshot();
  });

  it('static positioned elements near block-level ancestor', async () => {
    var p = document.createElement('p');
    document.body.appendChild(p);
    p.appendChild(document.createTextNode('Test passes if there is a filled green square and no red.'));

    var div1 = document.createElement('div');
    setStyle(div1, {
      background: 'red',
      display: 'block',
      height: '100px',
      width: '100px',
    });
    document.body.appendChild(div1);

    var div2 = document.createElement('div');
    setStyle(div2, {
      background: 'green',
      height: '100px',
      position: 'static',
      width: '100px',
    });
    div1.appendChild(div2);

    await matchScreenshot();
  });

  it('static positioned elements near block-level ancestor', async () => {
    var p = document.createElement('p');
    document.body.appendChild(p);
    p.appendChild(document.createTextNode('Test passes if there is a filled green square and no red.'));

    var div1 = document.createElement('div');
    setStyle(div1, {
      background: 'red',
      display: 'inline-block',
      height: '100px',
      width: '100px',
    });
    document.body.appendChild(div1);

    var div2 = document.createElement('div');
    setStyle(div2, {
      background: 'green',
      height: '100px',
      position: 'static',
      width: '100px',
    });
    div1.appendChild(div2);

    await matchScreenshot();
  });

  it('fixed positioned elements', async () => {
    var p = document.createElement('p');
    document.body.appendChild(p);
    p.appendChild(document.createTextNode('Test passes if there is a filled blue square in the upper-right corner of the page.'));

    var div1 = document.createElement('div');
    setStyle(div1, {
      position: 'relative',
      bottom: 0,
    });
    document.body.appendChild(div1);

    var div2 = document.createElement('div');
    setStyle(div2, {
      background: 'blue',
      height: '100px',
      position: 'fixed',
      right: 0,
      top: 0,
      width: '100px',
    });
    div1.appendChild(div2);

    await matchScreenshot();
  });

  it('absolute positioned elements near absolute ancestor', async () => {
    var p = document.createElement('p');
    document.body.appendChild(p);
    p.appendChild(document.createTextNode('Test passes if a filled blue square is in the upper-right corner of an hollow black square.'));

    var div1 = document.createElement('div');
    setStyle(div1, {
      border: '1px solid black',
      margin: '50px',
      position: 'absolute',
      top: 0,
    });
    document.body.appendChild(div1);

    var div2 = document.createElement('div');
    setStyle(div2, {
      margin: '50px',
      width: '50px',
      height: '50px',
    });
    div1.appendChild(div2);

    var div3 = document.createElement('div');
    setStyle(div3, {
      background: 'blue',
      right: 0,
      position: 'absolute',
      top: 0,
      width: '50px',
      height: '50px',
    });
    div2.appendChild(div3);
  });

  it('absolute positioned elements near relative ancestor', async () => {
    var p = document.createElement('p');
    document.body.appendChild(p);
    p.appendChild(document.createTextNode('Test passes if a filled blue square is in the upper-right corner of an hollow black square.'));

    var div1 = document.createElement('div');
    setStyle(div1, {
      border: '1px solid black',
      margin: '50px',
      position: 'relative',
      top: 0,
    });
    document.body.appendChild(div1);

    var div2 = document.createElement('div');
    setStyle(div2, {
      margin: '50px',
      width: '50px',
      height: '50px',
    });
    div1.appendChild(div2);

    var div3 = document.createElement('div');
    setStyle(div3, {
      background: 'blue',
      right: 0,
      position: 'absolute',
      top: 0,
      width: '50px',
      height: '50px',
    });
    div2.appendChild(div3);
  });

  it('absolute positioned elements near fixed ancestor', async () => {
    var p = document.createElement('p');
    document.body.appendChild(p);
    p.appendChild(document.createTextNode('Test passes if a filled blue square is in the upper-right corner of an hollow black square.'));

    var div1 = document.createElement('div');
    setStyle(div1, {
      border: '1px solid black',
      margin: '50px',
      position: 'fixed',
      top: 0,
    });
    document.body.appendChild(div1);

    var div2 = document.createElement('div');
    setStyle(div2, {
      margin: '50px',
      width: '50px',
      height: '50px',
    });
    div1.appendChild(div2);

    var div3 = document.createElement('div');
    setStyle(div3, {
      background: 'blue',
      right: 0,
      position: 'absolute',
      top: 0,
      width: '50px',
      height: '50px',
    });
    div2.appendChild(div3);
  });
});
