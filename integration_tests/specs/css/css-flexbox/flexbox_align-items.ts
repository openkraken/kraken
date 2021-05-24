/*auto generated*/
describe('flexbox_align-items', () => {
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
              height: '20px',
              display: 'block',
              position: 'absolute',
              top: '10px',
              left: '10px',
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
              display: 'block',
              position: 'absolute',
              top: '10px',
              left: '110px',
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
              height: '40px',
              display: 'block',
              position: 'absolute',
              top: '10px',
              left: '210px',
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
          'align-items': 'baseline',
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
              height: '20px',
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
              'margin-top': '10px',
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
              height: '40px',
              display: 'inline-block',
              flex: 'none',
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
  it('center-2-ref', async () => {
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
              height: '20px',
              position: 'absolute',
              top: '20px',
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
              height: '40px',
              position: 'absolute',
              top: '10px',
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
  it('center-2', async () => {
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
              height: '20px',
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
              height: '40px',
              display: 'inline-block',
              flex: 'none',
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
              height: '20px',
              position: 'absolute',
              top: '20px',
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
              height: '20px',
              position: 'absolute',
              top: '20px',
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
              height: '20px',
              position: 'absolute',
              top: '20px',
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
              height: '20px',
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
              height: '20px',
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
              height: '20px',
              display: 'inline-block',
              flex: 'none',
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
  it('flexend-2-ref', async () => {
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
              height: '30px',
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
  it('flexend-2', async () => {
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
              height: '30px',
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
  it('flexstart-2-ref', async () => {
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
              display: 'inline-block',
              position: 'absolute',
              top: '0',
              left: '10px',
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
              display: 'inline-block',
              position: 'absolute',
              top: '0',
              left: '110px',
              height: '30px',
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
              display: 'inline-block',
              position: 'absolute',
              top: '0',
              left: '210px',
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
  it('flexstart-2', async () => {
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
              height: '30px',
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
  it('stretch-2-ref', async () => {
    let div;
    let span;
    div = createElement('div', {
      style: {
        background: 'black',
        margin: '10px 0 0',
        width: '300px',
        height: '60px',
        'box-sizing': 'border-box',
      },
    });
    span = createElement(
      'span',
      {
        style: {
          display: 'inline-block',
          'box-sizing': 'border-box',
        },
      },
      [createText(`PASS`)]
    );
    BODY.appendChild(div);
    BODY.appendChild(span);

    await snapshot();
  });
  it('stretch-2', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'black',
          margin: '10px 0',
          width: '300px',
          height: '60px',
          display: 'flex',
          'align-items': 'stretch',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              width: '80px',
              display: 'inline-block',
              flex: 'none',
              'margin-top': '60px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`PASS`)]
        ),
        createElement('span', {
          style: {
            width: '80px',
            display: 'inline-block',
            flex: 'none',
            'box-sizing': 'border-box',
          },
        }),
        createElement(
          'span',
          {
            style: {
              width: '80px',
              display: 'inline-block',
              flex: 'none',
              'box-sizing': 'border-box',
            },
          },
          [createText(`x`)]
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
              margin: '0',
              width: '80px',
              height: '60px',
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
              margin: '0',
              width: '80px',
              height: '30px',
              position: 'absolute',
              top: '30px',
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
              margin: '0',
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
          'align-items': 'stretch',
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
              'margin-top': '30px',
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
