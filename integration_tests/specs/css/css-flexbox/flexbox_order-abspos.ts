/*auto generated*/
describe('flexbox_order-abspos', () => {
  it('space-around-ref', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          border: '1px solid black',
          width: '270px',
          height: '80px',
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
              width: '50px',
              height: '80px',
              position: 'absolute',
              top: '0',
              left: '20px',
              display: 'block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`filler`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'yellow',
              width: '50px',
              height: '80px',
              position: 'absolute',
              top: '0',
              left: '110px',
              display: 'block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`filler`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'yellow',
              width: '50px',
              height: '80px',
              position: 'absolute',
              top: '0',
              left: '200px',
              display: 'block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`filler`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
});
