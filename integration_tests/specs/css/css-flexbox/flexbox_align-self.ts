/*auto generated*/
describe('flexbox_align-self', () => {
  it('auto-ref', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          height: '60px',
          width: '300px',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              background: 'yellow',
              width: '80px',
              position: 'absolute',
              bottom: '0',
              left: '10px',
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
              width: '80px',
              position: 'absolute',
              bottom: '0',
              left: '110px',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`two`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'lightblue',
              width: '80px',
              position: 'absolute',
              bottom: '0',
              left: '210px',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`three`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
  it('auto', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          height: '60px',
          width: '300px',
          display: 'flex',
          'align-items': 'flex-end',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              background: 'yellow',
              margin: '0 10px',
              width: '80px',
              display: 'inline-block',
              flex: 'none',
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
              margin: '0 10px',
              width: '80px',
              display: 'inline-block',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          },
          [createText(`two`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'lightblue',
              margin: '0 10px',
              width: '80px',
              display: 'inline-block',
              flex: 'none',
              'align-self': 'auto',
              'box-sizing': 'border-box',
            },
          },
          [createText(`three`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
  it('baseline-ref', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          height: '60px',
          width: '300px',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              background: 'yellow',
              width: '80px',
              height: '30px',
              position: 'absolute',
              top: '15px',
              left: '10px',
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
              width: '80px',
              height: '30px',
              position: 'absolute',
              top: '15px',
              left: '110px',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`two`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'lightblue',
              width: '80px',
              height: '30px',
              position: 'absolute',
              top: '0',
              left: '210px',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`three`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
  it('baseline', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          height: '60px',
          width: '300px',
          display: 'flex',
          'align-items': 'center',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              background: 'yellow',
              margin: '0 10px',
              width: '80px',
              height: '30px',
              display: 'inline-block',
              flex: 'none',
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
              margin: '0 10px',
              width: '80px',
              height: '30px',
              display: 'inline-block',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          },
          [createText(`two`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'lightblue',
              margin: '0 10px',
              width: '80px',
              height: '30px',
              display: 'inline-block',
              flex: 'none',
              'align-self': 'baseline',
              'box-sizing': 'border-box',
            },
          },
          [createText(`three`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
  it('center-ref', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          height: '60px',
          width: '300px',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              background: 'yellow',
              width: '80px',
              position: 'absolute',
              top: '0',
              left: '10px',
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
              width: '80px',
              position: 'absolute',
              top: '0',
              left: '110px',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`two`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'lightblue',
              width: '80px',
              position: 'absolute',
              top: '10px',
              left: '210px',
              display: 'inline-block',
              height: '40px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`three`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
  it('center', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          height: '60px',
          width: '300px',
          display: 'flex',
          'align-items': 'flex-start',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              background: 'yellow',
              margin: '0 10px',
              width: '80px',
              display: 'inline-block',
              flex: 'none',
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
              margin: '0 10px',
              width: '80px',
              display: 'inline-block',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          },
          [createText(`two`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'lightblue',
              margin: '0 10px',
              width: '80px',
              display: 'inline-block',
              flex: 'none',
              height: '40px',
              'align-self': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`three`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
  it('flexend-ref', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          height: '60px',
          width: '300px',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              background: 'yellow',
              width: '80px',
              position: 'absolute',
              top: '0',
              left: '10px',
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
              width: '80px',
              position: 'absolute',
              top: '0',
              left: '110px',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`two`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'lightblue',
              width: '80px',
              position: 'absolute',
              top: 'auto',
              left: '210px',
              display: 'inline-block',
              bottom: '0',
              'box-sizing': 'border-box',
            },
          },
          [createText(`three`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
  it('flexend', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          height: '60px',
          width: '300px',
          display: 'flex',
          'align-items': 'flex-start',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              background: 'yellow',
              margin: '0 10px',
              width: '80px',
              display: 'inline-block',
              flex: 'none',
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
              margin: '0 10px',
              width: '80px',
              display: 'inline-block',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          },
          [createText(`two`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'lightblue',
              margin: '0 10px',
              width: '80px',
              display: 'inline-block',
              flex: 'none',
              'align-self': 'flex-end',
              'box-sizing': 'border-box',
            },
          },
          [createText(`three`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
  it('flexstart-ref', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          height: '60px',
          width: '300px',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              background: 'yellow',
              width: '80px',
              position: 'absolute',
              bottom: '0',
              left: '10px',
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
              width: '80px',
              position: 'absolute',
              bottom: '0',
              left: '110px',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`two`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'lightblue',
              width: '80px',
              position: 'absolute',
              bottom: 'auto',
              left: '210px',
              display: 'inline-block',
              top: '0',
              'box-sizing': 'border-box',
            },
          },
          [createText(`three`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
  it('flexstart', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          height: '60px',
          width: '300px',
          display: 'flex',
          'align-items': 'flex-end',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              background: 'yellow',
              margin: '0 10px',
              width: '80px',
              display: 'inline-block',
              flex: 'none',
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
              margin: '0 10px',
              width: '80px',
              display: 'inline-block',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          },
          [createText(`two`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'lightblue',
              margin: '0 10px',
              width: '80px',
              display: 'inline-block',
              flex: 'none',
              'align-self': 'flex-start',
              'box-sizing': 'border-box',
            },
          },
          [createText(`three`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
  it('stretch-ref', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          height: '60px',
          width: '300px',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              background: 'yellow',
              width: '80px',
              height: '30px',
              position: 'absolute',
              top: '15px',
              left: '10px',
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
              width: '80px',
              height: '30px',
              position: 'absolute',
              top: '15px',
              left: '110px',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`two`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'lightblue',
              width: '80px',
              height: '60px',
              position: 'absolute',
              top: '0',
              left: '210px',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`three`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
  it('stretch', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          height: '60px',
          width: '300px',
          display: 'flex',
          'align-items': 'center',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              background: 'yellow',
              margin: '0 10px',
              width: '80px',
              height: '30px',
              display: 'inline-block',
              flex: 'none',
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
              margin: '0 10px',
              width: '80px',
              height: '30px',
              display: 'inline-block',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          },
          [createText(`two`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'lightblue',
              margin: '0 10px',
              width: '80px',
              height: 'auto',
              display: 'inline-block',
              flex: 'none',
              'align-self': 'stretch',
              'box-sizing': 'border-box',
            },
          },
          [createText(`three`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
});
