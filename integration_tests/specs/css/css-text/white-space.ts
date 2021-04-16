describe('Text WhiteSpace', () => {
  it('should work with basic example', () => {
    // default to normal
    document.body.appendChild(
      document.createTextNode('\n there should \t\n\r be  no\n')
    );
    document.body.appendChild(document.createTextNode(' new line'));

    return snapshot();
  });

  it('should work with default value', () => {

    const cont = createElementWithStyle(
      'div',
      {
        width: '100px',
        backgroundColor: '#f40',
      },
      [
        createText('\n there should \t\n\r be\n new line'),
      ]
    );

    append(BODY, cont);

    return snapshot();
  });

  it('should work with normal', () => {

    const cont = createElementWithStyle(
      'div',
      {
        width: '100px',
        backgroundColor: '#f40',
        whiteSpace: 'normal',
      },
      [
        createText('\n there should \t\n\r be\n new line'),
      ]
    );

    append(BODY, cont);

    return snapshot();
  });

  it('should work with no-wrap', () => {

    const cont = createElementWithStyle(
      'div',
      {
        width: '100px',
        backgroundColor: '#f40',
        whiteSpace: 'nowrap',
      },
      [
        createText('\n there should \t\n\r be\n no new line'),
      ]
    );

    append(BODY, cont);

    return snapshot();
  });


  it('should work with value change from normal to nowrap', async (done) => {
    const cont = createElementWithStyle(
      'div',
      {
        width: '100px',
        backgroundColor: '#f40',
        whiteSpace: 'normal',
      },
      [
        createText('\n there should \t\n\r be\n no new line'),
      ]
    );

    append(BODY, cont);

    await snapshot();

    requestAnimationFrame(async () => {
      cont.style.whiteSpace = 'nowrap';
      await snapshot(0.1);
      done();
    });
  });

  it('should work with value change from nowrap to normal', async (done) => {
    const cont = createElementWithStyle(
      'div',
      {
        width: '100px',
        backgroundColor: '#f40',
        whiteSpace: 'nowrap',
      },
      [
        createText('\n there should \t\n\r be\n no new line'),
      ]
    );

    append(BODY, cont);

    await snapshot();

    requestAnimationFrame(async () => {
      cont.style.whiteSpace = 'normal';
      await snapshot(0.1);
      done();
    });
  });
});

describe('Inline level element', () => {
  it("should work with nowrap", async () => {
    let div;
    let span;
    div = createElement(
      'div',
      {
        style: {
          'white-space': 'nowrap',
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          width: '80px',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              background: 'yellow',
              margin: '10px 0',
              width: '50px',
              height: '50px',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`one`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'pink',
              margin: '10px 0',
              width: '50px',
              height: '50px',
              display: 'inline-block',
            },
          },
          [createText(`two`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'lightblue',
              margin: '10px 0',
              width: '50px',
              height: '50px',
              display: 'block',
            },
          },
          [createText(`three`)]
        ),
        (span = createElement(
          'span',
          {
            style: {
              background: 'grey',
              margin: '10px 0',
              width: '50px',
              height: '50px',
              display: 'inline-block',
            },
          },
          [createText(`four`)]
        )),
        (createElement(
          'span',
          {
            style: {
              background: 'green',
              margin: '10px 0',
              width: '50px',
              height: '50px',
              display: 'inline-block',
            },
          },
          [createText(`five`)]
        )),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it("should work with normal", async () => {
    let div;
    let span;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          width: '80px',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              background: 'yellow',
              margin: '10px 0',
              width: '50px',
              height: '50px',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`one`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'pink',
              margin: '10px 0',
              width: '50px',
              height: '50px',
              display: 'inline-block',
            },
          },
          [createText(`two`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'lightblue',
              margin: '10px 0',
              width: '50px',
              height: '50px',
              display: 'block',
            },
          },
          [createText(`three`)]
        ),
        (span = createElement(
          'span',
          {
            style: {
              background: 'grey',
              margin: '10px 0',
              width: '50px',
              height: '50px',
              display: 'inline-block',
            },
          },
          [createText(`four`)]
        )),
        (createElement(
          'span',
          {
            style: {
              background: 'green',
              margin: '10px 0',
              width: '50px',
              height: '50px',
              display: 'inline-block',
            },
          },
          [createText(`five`)]
        )),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it("should work with change from nowrap to normal", async (done) => {
    let div;
    let span;
    div = createElement(
      'div',
      {
        style: {
          'white-space': 'nowrap',
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          width: '80px',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              background: 'yellow',
              margin: '10px 0',
              width: '50px',
              height: '50px',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`one`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'pink',
              margin: '10px 0',
              width: '50px',
              height: '50px',
              display: 'inline-block',
            },
          },
          [createText(`two`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'lightblue',
              margin: '10px 0',
              width: '50px',
              height: '50px',
              display: 'block',
            },
          },
          [createText(`three`)]
        ),
        (span = createElement(
          'span',
          {
            style: {
              background: 'grey',
              margin: '10px 0',
              width: '50px',
              height: '50px',
              display: 'inline-block',
            },
          },
          [createText(`four`)]
        )),
        (createElement(
          'span',
          {
            style: {
              background: 'green',
              margin: '10px 0',
              width: '50px',
              height: '50px',
              display: 'inline-block',
            },
          },
          [createText(`five`)]
        )),
      ]
    );
    BODY.appendChild(div);

    await snapshot();

    requestAnimationFrame(async () => {
      div.style.whiteSpace = 'normal';
      await snapshot(0.1);
      done();
    });
  });

  it("should work with change from normal to nowrap", async (done) => {
    let div;
    let span;
    div = createElement(
      'div',
      {
        style: {
          'white-space': 'normal',
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          width: '80px',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              background: 'yellow',
              margin: '10px 0',
              width: '50px',
              height: '50px',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`one`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'pink',
              margin: '10px 0',
              width: '50px',
              height: '50px',
              display: 'inline-block',
            },
          },
          [createText(`two`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'lightblue',
              margin: '10px 0',
              width: '50px',
              height: '50px',
              display: 'block',
            },
          },
          [createText(`three`)]
        ),
        (span = createElement(
          'span',
          {
            style: {
              background: 'grey',
              margin: '10px 0',
              width: '50px',
              height: '50px',
              display: 'inline-block',
            },
          },
          [createText(`four`)]
        )),
        (createElement(
          'span',
          {
            style: {
              background: 'green',
              margin: '10px 0',
              width: '50px',
              height: '50px',
              display: 'inline-block',
            },
          },
          [createText(`five`)]
        )),
      ]
    );
    BODY.appendChild(div);

    await snapshot();

    requestAnimationFrame(async () => {
      div.style.whiteSpace = 'nowrap';
      await snapshot(0.1);
      done();
    });
  });
});


