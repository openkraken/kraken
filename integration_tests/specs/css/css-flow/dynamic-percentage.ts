/*auto generated*/
describe('dynamic-percentage', () => {
  it('height', async (done) => {
    let p;
    let block;
    let target;
    let container;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if there is a filled green square.`)]
    );
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          background: 'red',
          'box-sizing': 'border-box',
          border: 'solid green 10px',
          width: '100px',
          height: '100px',
        },
      },
      [
        (target = createElement(
          'div',
          {
            id: 'target',
            style: {
              height: '100%',
              'box-sizing': 'border-box',
            },
          },
          [
            (block = createElement('div', {
              id: 'block',
              style: {
                background: 'green',
                height: '80px',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(container);

    requestAnimationFrame(async () => {
      container.style.height = '100px';
      await snapshot();
      done();
    });
  });
});
