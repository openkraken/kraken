/*auto generated*/
describe('relpos-percentage', () => {
  xit('left-in-scrollable-2', async () => {
    let p;
    let container;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`There should be no red, and no scrollbar.`)]
    );
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          'box-sizing': 'border-box',
          overflow: 'auto',
          width: '500px',
          background: 'red',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
              'padding-right': '90%',
              background: 'yellow',
            },
          },
          [
            createElement(
              'div',
              {
                style: {
                  'box-sizing': 'border-box',
                  position: 'relative',
                  left: '900%',
                  background: 'cyan',
                },
              },
              [
                createElement('div', {
                  style: {
                    'box-sizing': 'border-box',
                  },
                }),
              ]
            ),
          ]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(container);

    container.scrollLeft = 123456;
    await snapshot();
  });
});
