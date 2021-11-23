/*auto generated*/
describe('flexbox_width-change', () => {
  it('and-relayout-children', async (done) => {
    let log;
    let child;
    let flexitem;
    let flexbox;
    let container;
    log = createElement('div', {
      id: 'log',
      style: {
        'box-sizing': 'border-box',
      },
    });
    container = createElement(
      'div',
      {
        id: 'container',
        'data-expected-width': '200',
        style: {
          'box-sizing': 'border-box',
          width: '100px',
        },
      },
      [
        (flexbox = createElement(
          'div',
          {
            class: 'flexbox column',
            'data-expected-width': '200',
            style: {
              'box-sizing': 'border-box',
            },
          },
          [
            (flexitem = createElement(
              'div',
              {
                class: 'flexitem',
                'data-expected-width': '200',
                style: {
                  'box-sizing': 'border-box',
                },
              },
              [
                (child = createElement(
                  'div',
                  {
                    class: 'child',
                    'data-expected-width': '200',
                    style: {
                      'background-color': 'salmon',
                      'box-sizing': 'border-box',
                    },
                  },
                  [createText(`This div should be 200px wide.`)]
                )),
              ]
            )),
          ]
        )),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(container);

    await snapshot();

    requestAnimationFrame(async () => {
      container.style.width = '200px';
      await snapshot();
      done();
    });

  });
});
