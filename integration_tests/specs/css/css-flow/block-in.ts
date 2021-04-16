/*auto generated*/
describe('block-in', () => {
  it('inline-003-ref', async () => {
    let div;
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          color: 'green',
        },
      },
      [createText(`There should be no red.`)]
    );
    BODY.appendChild(div);

    await snapshot();
  });
  it('inline-003', async () => {
    let block;
    let block_1;
    let inline;
    block_1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'block',
        style: {
          color: 'green',
          display: 'block',
          'box-sizing': 'border-box',
        },
      },
      [
        (inline = createElement(
          'div',
          {
            class: 'inline',
            style: {
              background: 'red',
              color: 'red',
              display: 'inline',
              'box-sizing': 'border-box',
            },
          },
          [
            (block = createElement(
              'div',
              {
                class: 'block',
                style: {
                  color: 'green',
                  display: 'block',
                  'box-sizing': 'border-box',
                },
              },
              [
                createText(`
     There should be no red.
    `),
              ]
            )),
          ]
        )),
      ]
    );
    BODY.appendChild(block);
    BODY.appendChild(block_1);

    await snapshot();
  });
  it('inline-004', async () => {
    let block;
    let block_1;
    let inline;
    block_1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'block',
        style: {
          display: 'block',
          'box-sizing': 'border-box',
        },
      },
      [
        (inline = createElement(
          'div',
          {
            class: 'inline',
            style: {
              color: 'blue',
              display: 'inline',
              'box-sizing': 'border-box',
            },
          },
          [
            createText(`
    The text of all 3 sentences should become green when you hover over any text.
    `),
            (block = createElement(
              'div',
              {
                class: 'block',
                style: {
                  display: 'block',
                  'box-sizing': 'border-box',
                },
              },
              [
                createText(`
     The text of all 3 sentences should become green when you hover over any text.
    `),
              ]
            )),
            createText(`
    The text of all 3 sentences should become green when you hover over any text.
   `),
          ]
        )),
      ]
    );
    BODY.appendChild(block);
    BODY.appendChild(block_1);

    await snapshot();
  });
  it('inline-005', async () => {
    let test;
    let inline;
    let block;
    block = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'block',
        style: {
          display: 'block',
          'box-sizing': 'border-box',
        },
      },
      [
        (inline = createElement(
          'div',
          {
            class: 'inline',
            style: {
              display: 'inline',
              'box-sizing': 'border-box',
            },
          },
          [
            createText(`
    This text should all collapse
    `),
            (test = createElement(
              'div',
              {
                class: 'block',
                id: 'test',
                style: {
                  display: 'block',
                  'box-sizing': 'border-box',
                },
              },
              [
                createText(`
     into one line of text when
    `),
              ]
            )),
            createText(`
    you click on the text.
   `),
          ]
        )),
      ]
    );
    BODY.appendChild(block);
    await snapshot();
  });
  it('inline-008-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [createText(`There should be no red.`)]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'background-color': 'green',
        height: '50px',
        width: '50px',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  it('inline-008', async () => {
    let p;
    let control;
    let block;
    let inline;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`There should be no red.`)]
    );
    control = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      class: 'control',
      style: {
        background: 'red',
        height: '50px',
        width: '50px',
        'box-sizing': 'border-box',
      },
    });
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        (inline = createElement(
          'div',
          {
            class: 'inline',
            style: {
              display: 'inline',
              'box-sizing': 'border-box',
            },
          },
          [
            (block = createElement('div', {
              class: 'block test',
              style: {
                display: 'block',
                background: 'green',
                height: '50px',
                width: '50px',
                position: 'relative',
                top: '-50px',
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(control);
    BODY.appendChild(div);

    await snapshot();
  });
  it('inline-relpos-001-ref', async () => {
    let p;
    let controlB;
    let controlB_1;
    let controlB_2;
    let controlB_3;
    let controlC;
    let controlC_1;
    let container;
    let container_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`The patterns in the 2 silver boxes must be `),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`identical`)]
        ),
        createText(`.`),
      ]
    );
    container = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'container',
        style: {
          margin: '10px',
          font: '20px/1 Ah0px',
          border: 'solid silver',
          width: '40px',
          color: 'aqua',
          background: 'fuchsia',
        },
      },
      [
        createText(`
    A`),
        (controlB = createElement(
          'span',
          {
            class: 'controlB',
            style: {
              color: 'yellow',
            },
          },
          [createText(`B`)]
        )),
        (controlC = createElement(
          'div',
          {
            class: 'controlC',
            style: {
              color: 'orange',
              background: 'orange',
              width: '20px',
              'margin-left': '0',
              'border-left': '20px solid blue',
            },
          },
          [createText(`C`)]
        )),
        createText(`
    A`),
        (controlB_1 = createElement(
          'span',
          {
            class: 'controlB',
            style: {
              color: 'yellow',
            },
          },
          [createText(`B`)]
        )),
      ]
    );
    container_1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'container',
        style: {
          margin: '10px',
          font: '20px/1 Ah0px',
          border: 'solid silver',
          width: '40px',
          color: 'aqua',
          background: 'fuchsia',
        },
      },
      [
        createText(`
    A`),
        (controlB_2 = createElement(
          'span',
          {
            class: 'controlB',
            style: {
              color: 'yellow',
            },
          },
          [createText(`B`)]
        )),
        (controlC_1 = createElement(
          'div',
          {
            class: 'controlC',
            style: {
              color: 'orange',
              background: 'orange',
              width: '20px',
              'margin-left': '0',
              'border-left': '20px solid blue',
            },
          },
          [createText(`C`)]
        )),
        createText(`
    A`),
        (controlB_3 = createElement(
          'span',
          {
            class: 'controlB',
            style: {
              color: 'yellow',
            },
          },
          [createText(`B`)]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(container);
    BODY.appendChild(container_1);

    await snapshot();
  });
  xit('inline-relpos-001', async () => {
    let p;
    let controlB;
    let controlB_1;
    let controlB_2;
    let controlB_3;
    let controlC;
    let controlC_1;
    let container;
    let container_1;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`The patterns in the 2 silver boxes must be `),
        createElement(
          'strong',
          {
            style: {},
          },
          [createText(`identical`)]
        ),
        createText(`.`),
      ]
    );
    container = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'container',
        style: {
          margin: '10px',
          font: '20px/1 Ah0px',
          border: 'solid silver',
          width: '40px',
          color: 'aqua',
          background: 'fuchsia',
        },
      },
      [
        createText(`
    A`),
        (controlB = createElement(
          'span',
          {
            class: 'controlB',
            style: {
              color: 'yellow',
            },
          },
          [createText(`B`)]
        )),
        (controlC = createElement(
          'div',
          {
            class: 'controlC',
            style: {
              color: 'orange',
              background: 'orange',
              width: '20px',
              'margin-left': '0',
              'border-left': '20px solid blue',
            },
          },
          [createText(`C`)]
        )),
        createText(`
    A`),
        (controlB_1 = createElement(
          'span',
          {
            class: 'controlB',
            style: {
              color: 'yellow',
            },
          },
          [createText(`B`)]
        )),
      ]
    );
    container_1 = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        class: 'container',
        style: {
          margin: '10px',
          font: '20px/1 Ah0px',
          border: 'solid silver',
          width: '40px',
          color: 'aqua',
          background: 'fuchsia',
        },
      },
      [
        createText(`
    A`),
        (controlB_2 = createElement(
          'span',
          {
            class: 'controlB',
            style: {
              color: 'yellow',
            },
          },
          [createText(`B`)]
        )),
        (controlC_1 = createElement(
          'div',
          {
            class: 'controlC',
            style: {
              color: 'orange',
              background: 'orange',
              width: '20px',
              'margin-left': '0',
              'border-left': '20px solid blue',
            },
          },
          [createText(`C`)]
        )),
        createText(`
    A`),
        (controlB_3 = createElement(
          'span',
          {
            class: 'controlB',
            style: {
              color: 'yellow',
            },
          },
          [createText(`B`)]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(container);
    BODY.appendChild(container_1);

    await snapshot();
  });
  xit('inline-empty-001-ref', async () => {
    let span;
    let span_1;
    span = createElement(
      'span',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
          display: 'block',
        },
      },
      [createText(`x`)]
    );
    span_1 = createElement('span', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'box-sizing': 'border-box',
        border: '5px solid blue',
        'border-left': 'none',
        'border-right': 'none',
        'padding-right': '10px',
      },
    });
    BODY.appendChild(span);
    BODY.appendChild(span_1);

    await snapshot();
  });
  it('inline-empty-003-ref', async () => {
    let span;
    let span_1;
    span = createElement('span', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'box-sizing': 'border-box',
        border: '5px solid blue',
        'border-left': 'none',
        'border-right': 'none',
        'padding-left': '10px',
      },
    });
    span_1 = createElement(
      'span',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
          display: 'block',
        },
      },
      [createText(`x`)]
    );
    BODY.appendChild(span);
    BODY.appendChild(span_1);

    await snapshot();
  });
  xit('inline-empty-003', async () => {
    let span;
    span = createElement(
      'span',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
          border: '5px solid blue',
          'border-left': 'none',
          'border-right': 'none',
          'padding-left': '10px',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              'box-sizing': 'border-box',
              display: 'block',
            },
          },
          [createText(`x`)]
        ),
      ]
    );
    BODY.appendChild(span);

    await snapshot();
  });
  xit('inline-empty-004', async () => {
    let span;
    span = createElement(
      'span',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
          border: '5px solid blue',
          'border-left': 'none',
          'border-right': 'none',
          'padding-left': '10px',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              'box-sizing': 'border-box',
              display: 'block',
            },
          },
          [createText(`x`)]
        ),
      ]
    );
    BODY.appendChild(span);

    await snapshot();
  });
});
