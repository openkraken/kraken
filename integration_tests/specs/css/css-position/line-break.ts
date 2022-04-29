/*auto generated*/
describe('line-break', () => {
  it('after-leading-float', async () => {
    let lime;
    let parent;
    parent = createElement(
      'div',
      {
        id: 'parent',
        style: {
          'box-sizing': 'border-box',
          width: '100px',
          'text-indent': '40px',
        },
      },
      [
        createElement('div', {
          style: {
            'box-sizing': 'border-box',
            // float: 'left',
            width: '60px',
            height: '10px',
            background: 'hotpink',
          },
        }),
        (lime = createElement('div', {
          id: 'lime',
          style: {
            'box-sizing': 'border-box',
            display: 'inline-block',
            width: '60px',
            height: '20px',
            background: 'lime',
          },
        })),
      ]
    );
    BODY.appendChild(parent);

    await snapshot();
  });

  // @TODO: Support text-indent.
  xit('after-leading-oof-001-ref', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          'text-indent': '3ch',
          'box-sizing': 'border-box',
        },
      },
      [createText(`123456`)]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  // @TODO: Support text-indent.
  xit('after-leading-oof-001', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '5ch',
          'text-indent': '3ch',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('span', {
          style: {
            'box-sizing': 'border-box',
            position: 'absolute',
          },
        }),
        createText(`123456`),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
});
