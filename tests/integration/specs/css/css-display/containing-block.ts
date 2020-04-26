describe('containing-block', () => {
  it('001', async () => {
    let div1 = createElement('div', {
      backgroundColor: 'red',
      display: 'block',
      width: '100px',
      height: '100px',
    });
    let child = createElement('div', {
      backgroundColor: 'green',
      height: '100px',
      width: '100px',
      position: 'relative',
    });
    append(div1, child);
    append(BODY, div1);
    await matchElementImageSnapshot(div1);
  });

  it('003', async () => {
    let div1 = createElement('div', {
      width: '60px',
      height: '60px',
      padding: '20px',
      display: 'inline-block',
      backgroundColor: 'red',
    });
    let child = createElement('div', {
      backgroundColor: 'green',
      height: '100px',
      width: '100px',
      left: '-20px',
      position: 'relative',
      top: '-20px',
    });
    append(div1, child);
    append(BODY, div1);
    await matchScreenshot();
  });

  xit('004', async () => {
    let div1 = createElement('div', {
      width: '100px',
      height: '100px',
      backgroundColor: 'red',
      display: 'block',
    });
    let child = createElement('div', {
      backgroundColor: 'green',
      height: '100%',
      width: '100%',
      position: 'static',
    });
    append(div1, child);
    append(BODY, div1);
    await matchElementImageSnapshot(div1);
  });

  it('007', async () => {
    let div1 = createElement('div', {
      position: 'relative',
      bottom: 0,
    });
    let child = createElement('div', {
      backgroundColor: 'blue',
      height: '100px',
      position: 'fixed',
      right: 0,
      top: 0,
      width: '100px',
    });
    append(div1, child);
    append(BODY, div1);
    await matchScreenshot();
  });

  it('008', async () => {
    let div1 = createElement('div', {
      border: '1px solid black',
      margin: '50px',
      position: 'absolute',
      top: 0,
    });
    let div2 = createElement('div', {
      margin: '50px',
      width: '100px',
      height: '100px',
    });
    let div3 = createElement('div', {
      backgroundColor: 'blue',
      right: 0,
      position: 'absolute',
      top: 0,
      width: '100px',
      height: '100px',
    });
    append(div2, div3);
    append(div1, div2);
    append(BODY, div1);
    await matchScreenshot();
  });
  xit('009', async () => {
    let div1 = createElement('div', {
      border: '1px solid black',
      margin: '50px',
      position: 'relative',
      top: 0,
    });
    let div2 = createElement('div', {
      margin: '50px',
      width: '100px',
      height: '100px',
    });
    let div3 = createElement('div', {
      backgroundColor: 'blue',
      right: 0,
      position: 'absolute',
      top: 0,
      width: '100px',
      height: '100px',
    });
    append(div2, div3);
    append(div1, div2);
    append(BODY, div1);
    await matchElementImageSnapshot(BODY);
  });
  xit('010', async () => {
    let div1 = createElement('div', {
      border: '1px solid black',
      margin: '50px',
      position: 'fixed',
      top: 0,
    });
    let div2 = createElement('div', {
      margin: '50px',
      width: '100px',
      height: '100px',
    });
    let div3 = createElement('div', {
      backgroundColor: 'blue',
      right: 0,
      position: 'absolute',
      top: 0,
      width: '100px',
      height: '100px',
    });
    append(div2, div3);
    append(div1, div2);
    append(BODY, div1);
    await matchElementImageSnapshot(BODY);
  });
  xit('011', async () => {
    let div2 = createElement('div', {
      border: '1px solid black',
      padding: '100px',
      position: 'relative',
      width: 0,
    });
    let span = createElement('span', {
      backgroundColor: 'blue',
      height: '100px',
      position: 'absolute',
      width: '100px',
    });
    append(div2, span);
    append(BODY, div2);
    await matchElementImageSnapshot(BODY);
  });
  xit('013', async () => {
    let div2 = createElement('div', {
      border: '1px solid black',
      padding: '100px',
      position: 'absolute',
      width: 0,
    });
    let span = createElement('span', {
      backgroundColor: 'blue',
      height: '100px',
      width: '100px',
      position: 'absolute',
    });
    append(div2, span);
    append(BODY, div2);
    await matchElementImageSnapshot(BODY);
  });
  xit('015', async () => {
    let div2 = createElement('div', {
      border: '1px solid black',
      padding: '100px',
      position: 'fixed',
      width: 0,
    });
    let span = createElement('span', {
      backgroundColor: 'blue',
      height: '100px',
      width: '100px',
      position: 'absolute',
    });
    append(div2, span);
    append(BODY, div2);
    await matchElementImageSnapshot(BODY);
  });

  xit('017', async () => {
    let divStyle = {
      border: '3px solid silver',
      marginBottom: '20px',
      padding: '100px',
      width: '450px',
    };
    let container = createElement('div', divStyle);
    let test = createElement('span', {
      border: '5px solid silver',
      padding: '50px',
      position: 'relative',
    });
    let firstBox = createElement('span', {
      color: 'silver',
    });
    let lastBox = createElement('span', {
      color: 'silver',
    });
    let tlControl = createElement('span', {
      borderTop: '30px solid red',
      marginLeft: '-50px',
      marginRight: '20px',
      padding: '20px 15px',
    });
    let brControl = createElement('span', {
      borderBottom: '30px solid red',
      marginLeft: '20px',
      marginRight: '-50px',
      padding: '20px 15px',
    });
    let positionStyle = {
      height: '30px',
      width: '30px',
      position: 'absolute',
    };
    let topLeftStyle = {
      backgroundColor: 'green',
      left: 0,
      top: 0,
    };
    let bottomrightStyle = {
      backgroundColor: 'green',
      bottom: 0,
      right: 0,
    };
    append(firstBox, tlControl);
    append(
      firstBox,
      createText('Filler Text Filler Text Filler Text Filler Text')
    );
    let BR = createElement('span', {
      ...positionStyle,
      ...bottomrightStyle,
    });
    append(BR, createText('BR'));
    append(test, BR);
    let TL = createElement('span', {
      ...positionStyle,
      ...topLeftStyle,
    });
    append(TL, createText('TL'));
    append(test, TL);
    append(
      lastBox,
      createText('Filler Text Filler Text Filler Text Filler Text')
    );
    append(lastBox, brControl);
    append(test, lastBox);
    append(container, test);
    append(BODY, container);
    await matchScreenshot();
  });

  xit('018', async () => {
    let divStyle = {
      border: '3px solid silver',
      marginBottom: '20px',
      padding: '100px',
      width: '450px',
    };
    let testStyle = {
      border: '5px solid silver',
      padding: '50px',
      position: 'relative',
    };
    let boxStyle = {
      color: 'silver',
    };
    let positionStyle = {
      height: '30px',
      width: '30px',
      position: 'absolute',
    };
    let trControlStyle = {
      borderTop: '30px solid red',
      marginLeft: '20px',
      marginRight: '-50px',
      padding: '20px 15px',
    };
    let blControlStyle = {
      borderBottom: '30px solid red',
      marginLeft: '-50px',
      marginRight: '20px',
      padding: '20px 15px',
    };
    let topRightStyle = {
      backgroundColor: 'green',
      right: 0,
      top: 0,
    };
    let bottomLeftStyle = {
      backgroundColor: 'green',
      bottom: 0,
      left: 0,
    };
    let container = createElement('div', divStyle);
    let test = createElement('span', testStyle);
    let firstBox = createElement('span', boxStyle);
    let trControl = createElement('span', trControlStyle);
    let BL = createElement('span', {
      ...positionStyle,
      ...bottomLeftStyle,
    });
    let TR = createElement('span', {
      ...positionStyle,
      ...topRightStyle,
    });
    let lastBox = createElement('span', boxStyle);
    let blControl = createElement('span', blControlStyle);

    append(firstBox, trControl);
    append(lastBox, blControl);
    append(test, firstBox);
    append(BL, createText('BL'));
    append(test, BL);
    append(TR, createText('TR'));
    append(test, TR);
    append(test, lastBox);
    append(container, test);
    append(BODY, container);
    await matchScreenshot();
  });

  xit('019', async () => {
    let divStyle = {
      border: '3px solid black',
      padding: '100px',
      position: 'absolute',
      width: 0,
    };
    let spanStyle = { display: 'block' };
    let spanSpanStyle = {
      backgroundColor: 'blue',
      height: '100px',
      left: 'auto',
      position: 'absolute',
      top: 'auto',
      width: '100px',
    };
    let div = createElement('div', divStyle);
    let span = createElement('span', spanStyle);
    let spanSpan = createElement('span', spanSpanStyle);
    append(span, spanSpan);
    append(div, span);
    append(BODY, div);
    await matchScreenshot();
  });

  it('023', async () => {
    let bodyStyle = {
      margin: '8px',
    };
    let div1Anddiv2Style = {
      margin: '100px',
    };
    let div3Style = {
      backgroundColor: 'blue',
      height: '100px',
      width: '100px',
      left: 0,
      bottom: 0,
      position: 'absolute',
    };
    setStyle(BODY, bodyStyle);
    let div1 = createElement('div', div1Anddiv2Style);
    let div2 = createElement('div', div1Anddiv2Style);
    let div3 = createElement('div', div3Style);
    append(div2, div3);
    append(div1, div2);
    append(BODY, div1);
    await matchScreenshot();
  });

  it('026', async () => {
    let divStyle = {
      backgroundColor: 'red',
      width: '100px',
      height: '100px',
    };
    let divDivStyle = {
      backgroundColor: 'green',
    };
    let child = createElement('div', {
      ...divStyle,
      ...divDivStyle,
    });
    let wrapper = createElement('div', divStyle);
    append(wrapper, child);
    append(BODY, wrapper);
    await matchElementImageSnapshot(wrapper);
  });

  it('027', async () => {
    let divStyle = {
      backgroundColor: 'blue',
      width: '100px',
      height: '100px',
      paddingTop: '5px',
    };
    let divDivStyle = {
      backgroundColor: 'orange',
      height: '50px',
      width: '200px',
    };
    let child = createElement('div', {
      ...divStyle,
      ...divDivStyle,
    });
    let wrapper = createElement('div', divStyle);
    append(wrapper, child);
    append(BODY, wrapper);
    await matchScreenshot();
  });

  it('028', async () => {
    let divStyle = {
      backgroundColor: 'blue',
      width: '100px',
      height: '100px',
      position: 'absolute',
    };
    let divDivStyle = {
      backgroundColor: 'orange',
      bottom: 0,
      right: 0,
      width: '25px',
      height: '25px',
    };
    let child = createElement('div', {
      ...divStyle,
      ...divDivStyle,
    });
    let wrapper = createElement('div', divStyle);
    append(wrapper, child);
    append(BODY, wrapper);
    await matchScreenshot();
  });

  it('030', async () => {
    let containingBlockStyle = {
      backgroundColor: 'blue',
      height: '100px',
      paddingLeft: '5px',
      width: '100px',
    };
    let soleChildStyle = {
      backgroundColor: 'orange',
      height: '200px',
      width: '50px',
    };
    let div = createElement('div', soleChildStyle);
    let container = createElement('div', containingBlockStyle);
    append(container, div);
    append(BODY, container);
    await matchScreenshot();
  });

  it('relative positioned elements near block-level ancestor', async () => {
    var p = document.createElement('p');
    document.body.appendChild(p);
    p.appendChild(
      document.createTextNode(
        'Test passes if there is a filled green square and no red.'
      )
    );

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
    p.appendChild(
      document.createTextNode(
        'Test passes if there is a filled green square and no red.'
      )
    );

    var div1 = document.createElement('div');
    setStyle(div1, {
      backgroundColor: 'red',
      display: 'inline-block',
      height: '60px',
      padding: '20px',
      width: '60px',
    });
    document.body.appendChild(div1);

    var div2 = document.createElement('div');
    setStyle(div2, {
      backgroundColor: 'green',
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
    p.appendChild(
      document.createTextNode(
        'Test passes if there is a filled green square and no red.'
      )
    );

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
    p.appendChild(
      document.createTextNode(
        'Test passes if there is a filled green square and no red.'
      )
    );

    var div1 = document.createElement('div');
    setStyle(div1, {
      backgroundColor: 'red',
      display: 'inline-block',
      height: '100px',
      width: '100px',
    });
    document.body.appendChild(div1);

    var div2 = document.createElement('div');
    setStyle(div2, {
      backgroundColor: 'green',
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
    p.appendChild(
      document.createTextNode(
        'Test passes if there is a filled blue square in the upper-right corner of the page.'
      )
    );

    var div1 = document.createElement('div');
    setStyle(div1, {
      position: 'relative',
      bottom: 0,
    });
    document.body.appendChild(div1);

    var div2 = document.createElement('div');
    setStyle(div2, {
      backgroundColor: 'blue',
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
    p.appendChild(
      document.createTextNode(
        'Test passes if a filled blue square is in the upper-right corner of an hollow black square.'
      )
    );

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
      backgroundColor: 'blue',
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
    p.appendChild(
      document.createTextNode(
        'Test passes if a filled blue square is in the upper-right corner of an hollow black square.'
      )
    );

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
      backgroundColor: 'blue',
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
    p.appendChild(
      document.createTextNode(
        'Test passes if a filled blue square is in the upper-right corner of an hollow black square.'
      )
    );

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
      backgroundColor: 'blue',
      right: 0,
      position: 'absolute',
      top: 0,
      width: '50px',
      height: '50px',
    });
    div2.appendChild(div3);
  });
});
