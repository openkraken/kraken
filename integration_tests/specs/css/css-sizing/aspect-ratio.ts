/*auto generated*/
describe('aspect-ratio', () => {
  it('affects-container-width-when-height-changes', async (done) => {
    let p;
    let container;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`There should be a green square below, and no red.`)]
    );
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          'box-sizing': 'border-box',
          height: '200px',
        },
      },
      [
        createElement(
          'div',
          {
            'data-expected-height': '100',
            style: {
              'box-sizing': 'border-box',
              height: '100%',
            },
          },
          [
            createElement(
              'div',
              {
                'data-expected-width': '100',
                'data-expected-height': '100',
                style: {
                  'box-sizing': 'border-box',
                  position: 'absolute',
                  height: '200px',
                  background: 'red',
                },
              },
              [
                createElement('img', {
                  src:
                    'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7',
                  'data-expected-width': '100',
                  'data-expected-height': '100',
                  style: {
                    'box-sizing': 'border-box',
                    display: 'block',
                    height: '200px',
                    background: 'green',
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

    requestAnimationFrame(async () => {
      const container = document.getElementById('container');
      if (container != null) {
        container.style.height = '100px';
      }
      await snapshot();
      done();
    });
  });
});
