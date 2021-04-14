/*auto generated*/
describe('overflow-recalc', () => {
  it('001', async () => {
    let p;
    let inlineinner;
    let inlineouter;
    let wrapper;
    let red;
    let scroller;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`no red`)]
        ),
        createText(`.`),
      ]
    );
    scroller = createElement(
      'div',
      {
        id: 'scroller',
        style: {
          height: '200px',
          overflow: 'scroll',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        (wrapper = createElement(
          'div',
          {
            id: 'wrapper',
            style: {
              'margin-top': '100px',
              width: '200px',
              height: '200px',
              overflow: 'hidden',
              'line-height': '1',
              position: 'relative',
              color: 'green',
              'box-sizing': 'border-box',
              zIndex: 1,
            },
          },
          [
            (inlineouter = createElement(
              'span',
              {
                id: 'inlineouter',
                style: {
                  'box-sizing': 'border-box',
                },
              },
              [
                (inlineinner = createElement(
                  'span',
                  {
                    id: 'inlineinner',
                    style: {
                      'box-sizing': 'border-box',
                      color: 'green',
                    },
                  },
                  [createText(`X`)]
                )),
              ]
            )),
          ]
        )),
        (red = createElement('div', {
          id: 'red',
          style: {
            background: 'red',
            width: '200px',
            height: '200px',
            position: 'absolute',
            top: '100px',
            'z-index': '-1',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(scroller);

    await snapshot();
  });
});
