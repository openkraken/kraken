/*auto generated*/
describe('flexbox_margin-auto', () => {
  it('overflow-ref', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          height: '80px',
          width: '320px',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              background: 'white',
              margin: '0',
              width: '300px',
              height: '60px',
              position: 'absolute',
              left: '0',
              top: '10px',
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
              background: 'yellow',
              margin: '0',
              width: '300px',
              height: '60px',
              position: 'absolute',
              left: '300px',
              top: '10px',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`two`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
  it('overflow', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          height: '80px',
          width: '320px',
          position: 'relative',
          display: 'flex',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              background: 'white',
              margin: '10px auto',
              width: '300px',
              display: 'inline-block',
              flex: '0 0 auto',
              'box-sizing': 'border-box',
            },
          },
          [createText(`one`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'yellow',
              margin: '10px auto',
              width: '300px',
              display: 'inline-block',
              flex: '0 0 auto',
              'box-sizing': 'border-box',
            },
          },
          [createText(`two`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
  it('ref', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          height: '80px',
          width: '320px',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              background: 'white',
              width: '40px',
              margin: '0',
              height: '60px',
              position: 'absolute',
              left: '60px',
              top: '10px',
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
              background: 'white',
              width: '40px',
              margin: '0',
              height: '60px',
              position: 'absolute',
              left: '220px',
              top: '10px',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`two`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
});
