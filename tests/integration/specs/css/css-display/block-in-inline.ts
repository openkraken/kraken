describe('Display block in inline', () => {
  it('simple', async () => {
    var div1 = document.createElement('div');
    setStyle(div1, {
      color: 'green',
      display: 'block',
    });
    var div2 = document.createElement('div');
    setStyle(div2, {
      background: 'red',
      color: 'red',
      display: 'inline',
    });
    var div3 = document.createElement('div');
    setStyle(div3, {
      color: 'green',
      display: 'block',
    });

    document.body.appendChild(div1);
    div1.appendChild(div2);
    div2.appendChild(div3);
    div3.appendChild(document.createTextNode('There should be no red.'));

    await matchScreenshot();
  });

  it('style changes 001', async () => {
    var div1 = document.createElement('div');
    setStyle(div1, {
      display: 'block',
    });
    var div2 = document.createElement('div');
    setStyle(div2, {
      display: 'inline',
    });
    div2.appendChild(document.createTextNode('This text should all collapse'));
    var div3 = document.createElement('div');
    setStyle(div3, {
      display: 'block',
    });
    div3.appendChild(document.createTextNode(' into one line of text when '));
    div2.appendChild(div3);
    div2.appendChild(document.createTextNode('you click on the text.'));

    document.body.appendChild(div1);
    div1.appendChild(div2);

    div1.addEventListener('click', () => {
      div3.style.display = div3.style.display == 'inline' ? 'block' : 'inline';
    });
    await matchScreenshot();
  });

  it('style changes 002', async () => {
    var div1 = document.createElement('div');
    setStyle(div1, {
      display: 'block',
    });
    var div2 = document.createElement('div');
    setStyle(div2, {
      display: 'inline',
    });
    div2.appendChild(document.createTextNode('This text should all split into'));
    var div3 = document.createElement('div');
    setStyle(div3, {
      display: 'inline',
    });
    div3.appendChild(document.createTextNode(' three separate lines when '));
    div2.appendChild(div3);
    div2.appendChild(document.createTextNode('you click on the text.'));

    document.body.appendChild(div1);
    div1.appendChild(div2);

    div1.addEventListener('click', () => {
      div2.style.display = div2.style.display == 'inline' ? 'block' : 'inline';
      div3.style.display = div3.style.display == 'inline' ? 'block' : 'inline';
    });
    await matchScreenshot();
  });

  it('relative positioning', async () => {
    var p = document.createElement('p');
    document.body.appendChild(p);
    p.appendChild(document.createTextNode('There should be no red.'));

    var div1 = document.createElement('div');
    setStyle(div1, {
      backgroundColor: 'red',
      height: '50px',
      width: '50px',
    });
    document.body.appendChild(div1);

    var div2 = document.createElement('div');
    document.body.appendChild(div2);

    var div3 = document.createElement('div');
    setStyle(div3, {
      display: 'inline',
    });
    div2.appendChild(div3);

    var div4 = document.createElement('div');
    setStyle(div4, {
      display: 'block',
      backgroundColor: 'green',
      height: '50px',
      width: '50px',
      position: 'relative',
      top: '-50px',
    });
    div3.appendChild(div4);

    await matchScreenshot();
  });
});
