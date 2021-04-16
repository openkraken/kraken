/*auto generated*/
describe('flexbox_box-clear', () => {
  it('ref', async () => {
    let float;
    let flex;
    float = createElement(
      'div',
      {
        id: 'float',
        style: {
          background: '#3366cc',
          padding: '10px',
          float: 'left',
          'box-sizing': 'border-box',
        },
      },
      [createText(`filler`)]
    );
    flex = createElement(
      'div',
      {
        id: 'flex',
        style: {
          background: '#ffcc00',
          padding: '20px',
          clear: 'both',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              background: 'pink',
              height: '40px',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`Yellow box should be below the blue box`)]
        ),
      ]
    );
    BODY.appendChild(float);
    BODY.appendChild(flex);

    await snapshot();
  });
});
