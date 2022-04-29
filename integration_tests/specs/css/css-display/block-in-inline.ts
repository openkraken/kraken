describe('Display block in inline', () => {
  // @TODO: background-color should not work for display: inline box.
  xit('simple', async () => {
    var div1 = document.createElement('div');
    setElementStyle(div1, {
      color: 'green',
      display: 'block',
    });
    var div2 = document.createElement('div');
    setElementStyle(div2, {
      background: 'red',
      color: 'red',
      display: 'inline',
    });
    var div3 = document.createElement('div');
    setElementStyle(div3, {
      color: 'green',
      display: 'block',
    });

    document.body.appendChild(div1);
    div1.appendChild(div2);
    div2.appendChild(div3);
    div3.appendChild(document.createTextNode('There should be no red.'));

    await snapshot();
  });

  it('style changes 001', async () => {
    var div1 = document.createElement('div');
    setElementStyle(div1, {
      display: 'block',
    });
    var div2 = document.createElement('div');
    setElementStyle(div2, {
      display: 'inline',
    });
    div2.appendChild(document.createTextNode('This text should all collapse'));
    var div3 = document.createElement('div');
    setElementStyle(div3, {
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
    await snapshot();
  });

  it('style changes 002', async () => {
    var div1 = document.createElement('div');
    setElementStyle(div1, {
      display: 'block',
    });
    var div2 = document.createElement('div');
    setElementStyle(div2, {
      display: 'inline',
    });
    div2.appendChild(
      document.createTextNode('This text should all split into')
    );
    var div3 = document.createElement('div');
    setElementStyle(div3, {
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
    await snapshot();
  });

  it('relative positioning', async () => {
    var p = document.createElement('p');
    document.body.appendChild(p);
    p.appendChild(document.createTextNode('There should be no red.'));

    var div1 = document.createElement('div');
    setElementStyle(div1, {
      backgroundColor: 'red',
      height: '50px',
      width: '50px',
    });
    document.body.appendChild(div1);

    var div2 = document.createElement('div');
    document.body.appendChild(div2);

    var div3 = document.createElement('div');
    setElementStyle(div3, {
      display: 'inline',
    });
    div2.appendChild(div3);

    var div4 = document.createElement('div');
    setElementStyle(div4, {
      display: 'block',
      backgroundColor: 'green',
      height: '50px',
      width: '50px',
      position: 'relative',
      top: '-50px',
    });
    div3.appendChild(div4);

    await snapshot();
  });

  // @TODO: background-color should not work for display: inline box.
  xit('there should be no red', async () => {
    let block = createElementWithStyle('div', {
      color: 'green',
      display: 'block',
    });
    let inline = createElementWithStyle('div', {
      background: 'red',
      color: 'red',
      display: 'inline',
    });
    let innerBlock = createElementWithStyle('div', {
      color: 'green',
      display: 'block',
    });
    let text = createText('There should be no red');
    append(innerBlock, text);
    append(inline, innerBlock);
    append(block, inline);
    append(BODY, block);
    await snapshot(block);
  });

  it('text should all coolapse into one line when click', async done => {
    const inlineStyle = { display: 'inline' };
    const blockStyle = { display: 'block' };

    let block = createElementWithStyle('div', blockStyle);
    let inline = createElementWithStyle('div', inlineStyle);
    let text1 = createText('This text should all collapse');
    let toggleBlock = createElementWithStyle('div', blockStyle);
    let text2 = createText('into one line of text when');
    let text3 = createText('you click on the text');

    append(toggleBlock, text2);
    append(inline, text1);
    append(inline, toggleBlock);
    append(inline, text3);
    append(block, inline);
    append(BODY, block);

    document.body.addEventListener('click', async function listener() {
      toggleBlock.style.display = 'inline';
      await snapshot(block);
      document.body.removeEventListener('click', listener);
      done();
    });

    await snapshot(block);

    document.body.click();
  });

  it('text should all split into three line when click', async done => {
    const inlineStyle = { display: 'inline' };
    const blockStyle = { display: 'block' };

    let block = createElementWithStyle('div', blockStyle);
    let inline = createElementWithStyle('div', inlineStyle);
    let text1 = createText('This text should split into');
    let toggleBlock = createElementWithStyle('div', inlineStyle);
    let text2 = createText('three separate lines when');
    let text3 = createText('you click on the text');

    append(toggleBlock, text2);
    append(inline, text1);
    append(inline, toggleBlock);
    append(inline, text3);
    append(block, inline);
    append(BODY, block);

    document.body.addEventListener('click', async function listener() {
      toggleBlock.style.display = 'block';
      await snapshot();
      document.body.removeEventListener('click', listener);
      done();
    });

    await snapshot();

    document.body.click();
  });

  it('There should be no red 2', async () => {
    const controlStyle = {
      backgroundColor: 'red',
      height: '50px',
      width: '50px',
    };
    const inlineStyle = { display: 'inline' };
    const blockStyle = { display: 'block' };
    const testStyle = {
      backgroundColor: 'green',
      height: '50px',
      width: '50px',
      position: 'relative',
      top: '-50px',
    };

    let control = createElementWithStyle('div', controlStyle);
    let wrap = createElementWithStyle('div', {});
    let inline = createElementWithStyle('div', inlineStyle);
    let block = createElementWithStyle('div', {
      ...blockStyle,
      ...testStyle,
    });
    append(inline, block);
    append(wrap, inline);
    append(BODY, control);
    append(BODY, wrap);
    await snapshot();
  });

  it('sliver boxs', async () => {
    const containerStyle = {
      margin: '20px',
      font: '40px',
      border: '1px solid sliver',
      width: '80px',
      color: 'aqua',
      backgroundColor: 'fuchsia',
    };
    const cStyle = {
      color: 'orange',
      backgroundColor: 'orange',
      width: '40px',
      marginLeft: '0',
      borderLeft: '40px solid blue',
    };
    const bStyle = {
      color: 'yellow',
    };
    let container = createElementWithStyle('div', containerStyle);
    let aText = createText(' A ');
    let bControl = createElementWithStyle('span', bStyle);
    let bText = createText('B');
    let cControl = createElementWithStyle('div', cStyle);
    let cText = createText('C');
    let aText2 = createText('  A');
    let bControl2 = createElementWithStyle('span', bStyle);
    let bText2 = createText('B');

    append(bControl, bText);
    append(bControl2, bText2);
    append(cControl, cText);
    append(container, aText);
    append(container, bControl);
    append(container, cControl);
    append(container, aText2);
    append(container, bControl2);
    append(BODY, container);

    await snapshot(container);
  });
});
