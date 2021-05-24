/*auto generated*/
describe('block-image', () => {
  xit('percentage-max-height-inside-inline', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green square and `),
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
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          width: '100px',
          height: '100px',
          background: 'red',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [
            createElement('img', {
              src:
                'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7',
              style: {
                'box-sizing': 'border-box',
                display: 'block',
                'max-width': '100px',
                height: '1000px',
                'max-height': '100%',
                background: 'green',
              },
            }),
          ]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
});
