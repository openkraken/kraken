/*auto generated*/
describe('flexbox_flow-row', () => {
  it('wrap-reverse', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          width: '200px',
          display: 'flex',
          'flex-flow': 'row wrap-reverse',
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
              width: '80px',
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
              width: '80px',
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
              width: '80px',
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
              width: '80px',
              display: 'inline-block',
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
  it('wrap', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          width: '200px',
          display: 'flex',
          'flex-flow': 'row wrap',
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
              width: '80px',
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
              width: '80px',
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
              width: '80px',
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
              width: '80px',
              display: 'inline-block',
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
