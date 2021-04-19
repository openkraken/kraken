/*auto generated*/
describe('canvas-intrinsic', () => {
  it('dynamic', async () => {
    let p;
    let target;
    let div;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if there is a filled green square.`)]
    );
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          position: 'absolute',
          background: 'green',
          'line-height': '0',
        },
      },
      [
        (target = createElement('canvas', {
          id: 'target',
          width: '100',
          height: '100',
          style: {
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
});
