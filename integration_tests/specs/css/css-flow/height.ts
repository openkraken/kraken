/*auto generated*/
describe('height', () => {
  it('001', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
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
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          background: 'red',
          height: '-1px',
          'box-sizing': 'border-box',
        },
      },
      [createText(`Filler Text`)]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('002', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
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
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          background: 'red',
          height: '0px',
          'box-sizing': 'border-box',
        },
      },
      [createText(`Filler Text`)]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('003', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if there is a thin horizontal line.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'black',
        height: '1px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('004', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
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
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          background: 'red',
          height: '-0px',
          'box-sizing': 'border-box',
        },
      },
      [createText(`Filler Text`)]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('005', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
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
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          background: 'red',
          height: '+0px',
          'box-sizing': 'border-box',
        },
      },
      [createText(`Filler Text`)]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('006', async () => {
    let p;
    let div2;
    let div3;
    let div1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if 2 black squares have the same height.`)]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        (div2 = createElement('div', {
          id: 'div2',
          style: {
            position: 'relative',
            background: 'black',
            height: '96px',
            width: '100px',
            'box-sizing': 'border-box',
          },
        })),
        (div3 = createElement('div', {
          id: 'div3',
          style: {
            position: 'absolute',
            'border-top': '96px solid black',
            left: '105px',
            top: '0',
            width: '100px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('007', async () => {
    let p;
    let div2;
    let div3;
    let div1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if 2 black squares have the same height.`)]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        (div2 = createElement('div', {
          id: 'div2',
          style: {
            position: 'relative',
            background: 'black',
            height: '+96px',
            width: '100px',
            'box-sizing': 'border-box',
          },
        })),
        (div3 = createElement('div', {
          id: 'div3',
          style: {
            position: 'absolute',
            'border-top': '96px solid black',
            left: '105px',
            top: '0',
            width: '100px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });

  it('should auto compute height when remove height property', async () => {
    let div;
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          background: 'red',
          height: '50px',
          'box-sizing': 'border-box',
        },
      },
      [createText(`Filler Text`)]
    );
    BODY.appendChild(div);

    await snapshot();

    div.style.height = null;

    await snapshot();
  });
});
