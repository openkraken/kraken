/*auto generated*/
describe('flexbox_width', () => {
  it('overflow', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'red',
          height: '40px',
          width: '0',
          overflow: 'hidden',
          display: 'flex',
          'justify-content': 'space-around',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'p',
          {
            style: {
              width: '200px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`one two three four`)]
        ),
        createElement(
          'p',
          {
            style: {
              width: '200px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`filler`)]
        ),
        createElement(
          'p',
          {
            style: {
              width: '200px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`filler`)]
        ),
        createElement(
          'p',
          {
            style: {
              width: '200px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`filler`)]
        ),
        createElement(
          'p',
          {
            style: {
              width: '200px',
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
