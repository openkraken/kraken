/*auto generated*/
describe('dynamic-top', () => {
  it('change-001-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'line-height': '1.25',
          margin: '10px 0',
        },
      },
      [
        createText(`Test passes if there is `),
        createElement(
          'strong',
          {
            style: {
              'line-height': '1',
            },
          },
          [createText(`no red`)]
        ),
        createText(`.`),
      ]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'background-color': 'green',
        height: '100px',
        'margin-top': '112px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('change-002-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'line-height': '1.25',
          margin: '10px 0',
        },
      },
      [
        createText(`Test passes if there is `),
        createElement(
          'strong',
          {
            style: {
              'line-height': '1',
            },
          },
          [createText(`no red`)]
        ),
        createText(`.`),
      ]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'background-color': 'green',
        height: '100px',
        'margin-top': '28px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('change-004', async () => {
    let p;
    let red;
    let parent;
    let green;
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
    parent = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'parent',
        style: {
          'box-sizing': 'border-box',
          top: '20px',
        },
      },
      [
        (red = createElement('div', {
          id: 'red',
          class: 'testDiv',
          style: {
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    green = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'green',
      class: 'testDiv',
      style: {
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(parent);
    BODY.appendChild(green);

    window.onload = function () {
      document.body.offsetWidth;
      parent.style.top = '2em';
    };

    await snapshot();
  });

  // @TODO: Support CSS inherit keyword.
  xit('change-005', async () => {
    let p;
    let red;
    let parent;
    let grandparent;
    let green;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if there is no red.`)]
    );
    grandparent = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'grandparent',
        style: {
          position: 'absolute',
          top: '0',
        },
      },
      [
        (parent = createElement(
          'span',
          {
            id: 'parent',
            style: {
              position: 'relative',
              top: '50px',
            },
          },
          [
            (red = createElement('span', {
              id: 'red',
              class: 'testDiv',
              style: {
                position: 'relative',
                width: '100px',
                height: '100px',
                top: 'inherit',
                background: 'red',
                display: 'block',
              },
            })),
          ]
        )),
      ]
    );
    green = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'green',
      class: 'testDiv',
      style: {
        position: 'relative',
        width: '100px',
        height: '100px',
        top: '100px',
        background: 'green',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(grandparent);
    BODY.appendChild(green);

    window.onload = function () {
      document.body.offsetWidth;
      parent.style.top = '50px';
    };

    await snapshot();
  });

  // @TODO: Support CSS inherit keyword.
  xit('change-005a', async () => {
    let p;
    let red;
    let parent;
    let grandparent;
    let green;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if there is no red.`)]
    );
    grandparent = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'grandparent',
        style: {
          position: 'absolute',
          top: '0',
        },
      },
      [
        (parent = createElement(
          'div',
          {
            id: 'parent',
            style: {
              position: 'relative',
              top: '50px',
            },
          },
          [
            (red = createElement('span', {
              id: 'red',
              class: 'testDiv',
              style: {
                position: 'relative',
                width: '100px',
                height: '100px',
                top: 'inherit',
                background: 'red',
                display: 'block',
              },
            })),
          ]
        )),
      ]
    );
    green = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'green',
      class: 'testDiv',
      style: {
        position: 'relative',
        width: '100px',
        height: '100px',
        top: '100px',
        background: 'green',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(grandparent);
    BODY.appendChild(green);

    window.onload = function () {
      document.body.offsetWidth;
      parent.style.top = '50px';
    };

    await snapshot();

    await snapshot();
  });

  // @TODO: Support CSS inherit keyword.
  xit('change-005b', async () => {
    let p;
    let red;
    let parent;
    let grandparent;
    let green;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if there is no red.`)]
    );
    grandparent = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'grandparent',
        style: {
          position: 'absolute',
          top: '0',
        },
      },
      [
        (parent = createElement(
          'span',
          {
            id: 'parent',
            style: {
              position: 'relative',
              top: '50px',
            },
          },
          [
            (red = createElement('span', {
              id: 'red',
              class: 'testDiv',
              style: {
                position: 'relative',
                width: '100px',
                height: '100px',
                top: 'inherit',
                background: 'red',
                display: 'block',
              },
            })),
          ]
        )),
      ]
    );
    green = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'green',
      class: 'testDiv',
      style: {
        position: 'relative',
        width: '100px',
        height: '100px',
        top: '100px',
        background: 'green',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(grandparent);
    BODY.appendChild(green);

    await snapshot();
  });
});
