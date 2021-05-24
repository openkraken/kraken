/*auto generated*/
describe('toogle-abspos', () => {
  it('on-relpos-inline-child', async () => {
    let p;
    let victim;
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
          width: '50px',
          height: '50px',
          'padding-left': '50px',
          'padding-top': '50px',
          background: 'red',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              'box-sizing': 'border-box',
              position: 'relative',
            },
          },
          [
            (victim = createElement('div', {
              id: 'victim',
              style: {
                'box-sizing': 'border-box',
                position: 'absolute',
                top: '-50px',
                left: '-50px',
                width: '100px',
                height: '100px',
                background: 'green',
              },
            })),
          ]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    document.body.offsetTop;
    victim.style.position = 'static';
    document.body.offsetTop;
    victim.style.position = 'absolute';

    await snapshot();
  });
});
