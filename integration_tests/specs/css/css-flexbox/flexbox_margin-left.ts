/*auto generated*/
describe('flexbox_margin-left', () => {
  it('ex-ref', async () => {
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
              height: '60px',
              display: 'inline-block',
              position: 'absolute',
              right: '10px',
              top: '10px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`four`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'white',
              margin: '10px',
              height: '60px',
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
              margin: '10px',
              height: '60px',
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
              background: 'white',
              margin: '10px',
              height: '60px',
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
  it('ex', async () => {
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
              margin: '10px',
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
              margin: '10px',
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
              background: 'white',
              margin: '10px',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`three`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'white',
              margin: '10px',
              display: 'inline-block',
              'margin-left': 'auto',
              'box-sizing': 'border-box',
            },
          },
          [createText(`four`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
});
