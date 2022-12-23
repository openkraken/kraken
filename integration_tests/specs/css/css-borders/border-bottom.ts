/*auto generated*/
describe('border-bottom', () => {
  it('001-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if there is a filled black square.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'background-color': 'black',
        height: '100px',
        position: 'relative',
        top: '100px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
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
      [createText(`Test passes if there is a filled black square.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'border-bottom': '100px',
        'border-bottom-style': 'solid',
        height: '100px',
        width: '100px',
        'box-sizing': 'border-box',
      },
    });
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
      [createText(`Test passes if there is a blue line.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'border-bottom': 'blue',
        'border-bottom-style': 'solid',
        height: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('005-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if there is a filled blue square.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'background-color': 'blue',
        height: '100px',
        position: 'relative',
        top: '100px',
        width: '100px',
      },
    });
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
      [createText(`Test passes if there is a filled blue square.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'border-bottom': '100px solid blue',
        height: '100px',
        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('006', async () => {
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
      [createText(`Test passes if there is a filled black square.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'border-bottom': '100px solid #000',
        height: '100px',
        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('008', async () => {
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
      [createText(`Test passes if there is a filled blue square.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'border-bottom': '100px solid blue',
        height: '100px',
        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('010', async () => {
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
      [createText(`Test passes if there is a dashed blue line below.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'border-bottom': '5px solid blue',
        height: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('016-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if there are 2 black lines.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'background-color': 'black',
        height: '3px',
        'margin-top': '112px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'background-color': 'black',
        height: '3px',
        'margin-top': '10px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot();
  });
  it('016', async () => {
    let p;
    let div1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if there are 2 black lines.`)]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          'border-bottom': '4px solid #000',
          'padding-bottom': '10px',
          height: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            height: '100px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('018-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if there are 2 large blue rectangles.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'background-color': 'blue',
        height: '96px',
        'margin-top': '112px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'background-color': 'blue',
        height: '96px',
        'margin-top': '10px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot();
  });
  it('018', async () => {
    let p;
    let div1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if there are 2 large blue rectangles.`)]
    );
    div1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'div1',
        style: {
          'border-bottom': '100px solid blue',
          'padding-bottom': '10px',
          height: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            height: '100px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div1);

    await snapshot();
  });
  it('applies-to-001-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if there is a short horizontal green line.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'background-color': 'green',
        height: '3px',
        width: '96px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('applies-to-008', async () => {
    let div;
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'border-bottom': '10px solid green',
          display: 'inline',
          'font-size': '100px',
          'box-sizing': 'border-box',
        },
      },
      [createText(`1111`)]
    );
    BODY.appendChild(div);

    await snapshot();
  });
  it('applies-to-009', async () => {
    let div;
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('span', {
          style: {
            'border-bottom': '3px solid green',
            display: 'block',
            width: '100px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
  it('applies-to-012', async () => {
    let p;
    let blockDescendant;
    let blockDescendant_1;
    let inlineBlock;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if there is a short horizontal green line.`)]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        (inlineBlock = createElement(
          'span',
          {
            id: 'inline-block',
            style: {
              'border-bottom': '3px solid green',
              display: 'inline-block',
              'vertical-align': 'top',
              width: '100px',
              'box-sizing': 'border-box',
            },
          },
          [
            (blockDescendant = createElement('span', {
              class: 'block-descendant',
              style: {
                display: 'block',
                'box-sizing': 'border-box',
              },
            })),
            (blockDescendant_1 = createElement('span', {
              class: 'block-descendant',
              style: {
                display: 'block',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('color-001-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/000_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/000_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot();
  });
  it('color-001', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#00000',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#000000',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-002', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#000000',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#000000',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-003-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/010101_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/010101_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await sleep(0.5);
    await snapshot();
  });
  it('color-003', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#010101',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#010101',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-004-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/999_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/999_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot(0.1);
  });
  it('color-004', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#999999',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#999999',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-005-ref', async () => {
    let div;
    let div_1;
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/fefefe_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/fefefe_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot(0.1);
  });
  it('color-005', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          color: 'white',
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#fefefe',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#fefefe',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-006-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          color: 'white',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/000_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/000_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot(0.1);
  });
  it('color-006', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          color: 'white',
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#000',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#000',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-007', async () => {
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
      [createText(`Test passes if there is a filled black square.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#1000000',

        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('color-008', async () => {
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
      [createText(`Test passes if there is a filled black square.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#fgfgfg',

        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('color-009-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/010000_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/010000_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot(0.1);
  });
  it('color-009', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#010000',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#010000',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-010-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'background-color': '#990000',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'background-color': '#990000',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot();
  });
  it('color-010', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#990000',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#990000',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-011-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/fe0000_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/fe0000_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot(0.1);
  });
  it('color-011', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#fe0000',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#fe0000',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-012-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/f00_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/f00_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot(0.1);
  });
  it('color-012', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#ff0000',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#ff0000',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-013', async () => {
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
      [createText(`Test passes if there is a filled black square.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#fg0000',

        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('color-014-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/000100_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/000100_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot(0.1);
  });
  it('color-014', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#000100',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#000100',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-015-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/090_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/090_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot(0.1);
  });
  it('color-015', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#009900',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#009900',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-016-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/00fe00_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/00fe00_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot(0.1);
  });
  it('color-016', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#00fe00',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#00fe00',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-017-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/0f0_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/0f0_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot(0.1);
  });
  it('color-017', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#00ff00',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#00ff00',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-018', async () => {
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
      [createText(`Test passes if there is a filled black square.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#00fg00',

        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('color-019-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/000001_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/000001_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot(0.1);
  });
  it('color-019', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#000001',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#000001',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-020-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/009_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/009_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot(0.1);
  });
  it('color-020', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#000099',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#000099',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-021-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/0000fe_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/0000fe_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot(0.1);
  });
  it('color-021', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#0000fe',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#0000fe',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-022-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/00f_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/00f_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot(0.1);
  });
  it('color-022', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#0000ff',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#0000ff',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-023', async () => {
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
      [createText(`Test passes if there is a filled black square.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#0000fg',

        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('color-024', async () => {
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
      [createText(`Test passes if there is a filled black square.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#00',

        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('color-025', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#000',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#000',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-026-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/111_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/111_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot(0.1);
  });
  it('color-026', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#111',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#111',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-027-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/999_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/999_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot(0.1);
  });
  it('color-027', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#999',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#999',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-028-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/eee_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/eee_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot(0.1);
  });
  it('color-028', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#eee',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#eee',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-030', async () => {
    let p;
    let test;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there is a filled black or transparent square surrounded by a blue border.`
        ),
      ]
    );
    test = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'test',
        style: {
          border: '5px solid blue',
          height: '100px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'border-bottom-style': 'solid',
            'border-bottom-width': '100px',
            'border-bottom-color': '#1000',

            width: '100px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(test);

    await snapshot();
  });
  it('color-031', async () => {
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
      [createText(`Test passes if there is a filled black square.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#ggg',

        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('color-032-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/100_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/100_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot(0.1);
  });
  it('color-032', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#100',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#100',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-033', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#900',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#900',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-034-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/e00_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/e00_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot(0.1);
  });
  it('color-034', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#e00',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#e00',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-035', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#f00',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#f00',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-036', async () => {
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
      [createText(`Test passes if there is a filled black square.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#g00',

        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('color-037-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/010_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/010_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await sleep(0.5);

    await snapshot(0.1);
  });
  it('color-037', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#010',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#010',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-038-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/090_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/090_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot(0.1);
  });
  it('color-038', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#090',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#090',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-039-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/0e0_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/0e0_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot(0.1);
  });
  it('color-039', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#0e0',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#0e0',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-040', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#0f0',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#0f0',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-041', async () => {
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
      [createText(`Test passes if there is a filled black square.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#0g0',

        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('color-042-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/001_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/001_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot(0.1);
  });
  it('color-042', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#001',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#001',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-043', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#009',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#009',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-044-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/00e_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/00e_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot(0.1);
  });
  it('color-044', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#00e',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#00e',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-045', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#00f',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': '#00f',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-046', async () => {
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
      [createText(`Test passes if there is a filled black square.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': '#00g',

        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('color-047', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(-1%, -1%, -1%)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0%, 0%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-048', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(0%, 0%, 0%)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0%, 0%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-049-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(1%, 1%, 1%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(1%, 1%, 1%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot();
  });
  it('color-049', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(1%, 1%, 1%)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(1%, 1%, 1%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-050', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(-0%, -0%, -0%)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0%, 0%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-051', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(+0%, +0%, +0%)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0%, 0%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-052-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(40%, 40%, 40%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(40%, 40%, 40%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot();
  });
  it('color-053', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(+40%, +40%, +40%)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(40%, 40%, 40%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-054-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          color: 'white',
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(99%, 99%, 99%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(99%, 99%, 99%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot();
  });
  it('color-054', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          color: 'white',
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(99%, 99%, 99%)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(99%, 99%, 99%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-063-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/808080_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/808080_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot(0.2);
  });
  it('color-063', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(128, 128, 128)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(128, 128, 128)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-064', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(+128, +128, +128)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(128, 128, 128)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-070-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(1%, 0%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(1%, 0%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot();
  });
  it('color-070', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(1%, 0%, 0%)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(1%, 0%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-071', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(-0%, 0%, 0%)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0%, 0%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-073-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(40%, 0%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(40%, 0%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot();
  });
  it('color-073', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(40%, 0%, 0%)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(40%, 0%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-074', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(+40%, 0%, 0%)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(40%, 0%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-075-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(99%, 0%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(99%, 0%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot();
  });
  it('color-075', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(99%, 0%, 0%)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(99%, 0%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-076', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(100%, 0%, 0%)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(100%, 0%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-077', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(+100%, 0%, 0%)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(100%, 0%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-078', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(101%, 0%, 0%)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(100%, 0%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-079', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(-1, 0, 0)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0, 0, 0)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-080', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(1, 0, 0)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(1, 0, 0)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-081', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(-0, 0, 0)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0, 0, 0)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-082', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(+0, 0, 0)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0, 0, 0)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-083-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/800000_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/800000_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot(0.2);
  });
  it('color-083', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(128, 0, 0)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(128, 0, 0)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-084', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(+128, 0, 0)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(128, 0, 0)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-085', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(254, 0, 0)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(254, 0, 0)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-086', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(255, 0, 0)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(255, 0, 0)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-087', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(+255, 0, 0)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(255, 0, 0)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-088', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(256, 0, 0)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(255, 0, 0)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-089', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(0%, -1%, 0%)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0%, 0%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-090-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0%, 1%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0%, 1%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot();
  });
  it('color-090', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(0%, 1%, 0%)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0%, 1%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-093-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0%, 40%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0%, 40%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot();
  });
  it('color-093', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(0%, 40%, 0%)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0%, 40%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-094', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(0%, +40%, 0%)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0%, 40%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-095-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0%, 99%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0%, 99%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot();
  });
  it('color-095', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(0%, 99%, 0%)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0%, 99%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-096', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(0%, 100%, 0%)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0%, 100%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-097', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(0%, +100%, 0%)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0%, 100%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-098', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(0%, 101%, 0%)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0%, 100%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-099', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(0, -1, 0)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0, 0, 0)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-100-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'background-color': 'rgb(0, 1, 0)',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'background-color': 'rgb(0, 1, 0)',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot();
  });
  it('color-100', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(0, 1, 0)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0, 1, 0)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-101', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(0, -0, 0)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0, 0, 0)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-102', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(0, +0, 0)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0, 0, 0)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-103-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/008000_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        background: 'url("assets/008000_color.png")',
        height: '100px',
        'margin-top': '10px',
        width: '100px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot(0.2);
  });
  it('color-103', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(0, 128, 0)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0, 128, 0)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-105', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(0, 254, 0)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0, 254, 0)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-106', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(0, 255, 0)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0, 255, 0)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-107', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(0, +255, 0)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0, 255, 0)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-108', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(0, 256, 0)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0, 255, 0)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-109', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(0%, 0%, -1%)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0%, 0%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-110-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0%, 0%, 1%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0%, 0%, 1%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot();
  });
  it('color-110', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(0%, 0%, 1%)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0%, 0%, 1%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-111', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(0%, 0%, -0%)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0%, 0%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-112', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {

        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(0%, 0%, +0%)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0%, 0%, 0%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-113-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0%, 0%, 40%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0%, 0%, 40%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot();
  });
  it('color-113', async () => {
    let p;
    let test;
    let reference;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    test = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'test',
      style: {
        width: '100px',
        'border-bottom-style': 'solid',
        'border-bottom-width': '100px',
        'border-bottom-color': 'rgb(0%, 0%, 40%)',
        'box-sizing': 'border-box',
      },
    });
    reference = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      id: 'reference',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0%, 0%, 40%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(test);
    BODY.appendChild(reference);

    await snapshot();
  });
  it('color-115-ref', async () => {
    let p;
    let div;
    let div_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if the boxes below are the same color.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0%, 0%, 99%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    div_1 = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        height: '100px',
        width: '100px',
        'background-color': 'rgb(0%, 0%, 99%)',
        'margin-top': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    await snapshot();
  });
});
