/*auto generated*/
describe('flex-direction', () => {
  it('modify', async () => {
    let flexItem;
    let flexItem_1;
    let flexItem_2;
    let flexContainer;
    flexContainer = createElement(
      'div',
      {
        id: 'flex_container',
        class: 'flex-container flex-direction-row',
        style: {
          display: 'flex',
          margin: '20px',
          background: '#333',
          'flex-direction': 'row',
          'box-sizing': 'border-box',
        },
      },
      [
        (flexItem = createElement(
          'div',
          {
            class: 'flex-item',
            style: {
              display: 'inline-block',
              width: '50px',
              height: '50px',
              margin: '20px',
              background: '#eee',
              'line-height': '50px',
              'text-align': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1`)]
        )),
        (flexItem_1 = createElement(
          'div',
          {
            class: 'flex-item',
            style: {
              display: 'inline-block',
              width: '50px',
              height: '50px',
              margin: '20px',
              background: '#eee',
              'line-height': '50px',
              'text-align': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`2`)]
        )),
        (flexItem_2 = createElement(
          'div',
          {
            class: 'flex-item',
            style: {
              display: 'inline-block',
              width: '50px',
              height: '50px',
              margin: '20px',
              background: '#eee',
              'line-height': '50px',
              'text-align': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`3`)]
        )),
      ]
    );
    BODY.appendChild(flexContainer);

    await snapshot();
  });
  it('with-element-insert', async () => {
    let flexItem;
    let flexItem_1;
    let flexItem_2;
    let flexItem_3;
    let flexItem_4;
    let flexItem_5;
    let flexItem_6;
    let flexItem_7;
    let flexItem_8;
    let flexItem_9;
    let flexItem_10;
    let flexItem_11;
    let flexItem_12;
    let flexItem_13;
    let flexItem_14;
    let flexItem_15;
    let flexContainer;
    let flexContainer_1;
    let flexContainer_2;
    let flexContainer_3;
    flexContainer = createElement(
      'div',
      {
        class: 'flex-container flex-direction-row',
        style: {
          display: 'block',
          margin: '20px',
          background: '#333',
          'line-height': '0px',
          'flex-direction': 'row',
          'box-sizing': 'border-box',
        },
      },
      [
        (flexItem = createElement(
          'div',
          {
            class: 'flex-item',
            style: {
              display: 'inline-block',
              width: '50px',
              height: '50px',
              margin: '20px 20px',
              background: '#eee',
              'line-height': '50px',
              'text-align': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1`)]
        )),
        (flexItem_1 = createElement(
          'div',
          {
            class: 'flex-item',
            style: {
              display: 'inline-block',
              width: '50px',
              height: '50px',
              margin: '20px 20px',
              background: '#eee',
              'line-height': '50px',
              'text-align': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`2`)]
        )),
        (flexItem_2 = createElement(
          'div',
          {
            class: 'flex-item',
            style: {
              display: 'inline-block',
              width: '50px',
              height: '50px',
              margin: '20px 20px',
              background: '#eee',
              'line-height': '50px',
              'text-align': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`3`)]
        )),
        (flexItem_3 = createElement(
          'div',
          {
            class: 'flex-item',
            style: {
              display: 'inline-block',
              width: '50px',
              height: '50px',
              margin: '20px 20px',
              background: '#eee',
              'line-height': '50px',
              'text-align': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`new`)]
        )),
      ]
    );
    flexContainer_1 = createElement(
      'div',
      {
        class: 'flex-container flex-direction-row-reverse',
        style: {
          display: 'block',
          margin: '20px',
          background: '#333',
          'line-height': '0px',
          'text-align': 'right',
          'box-sizing': 'border-box',
        },
      },
      [
        (flexItem_4 = createElement(
          'div',
          {
            class: 'flex-item',
            style: {
              display: 'inline-block',
              width: '50px',
              height: '50px',
              margin: '20px 20px',
              background: '#eee',
              'line-height': '50px',
              'text-align': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`new`)]
        )),
        (flexItem_5 = createElement(
          'div',
          {
            class: 'flex-item',
            style: {
              display: 'inline-block',
              width: '50px',
              height: '50px',
              margin: '20px 20px',
              background: '#eee',
              'line-height': '50px',
              'text-align': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`3`)]
        )),
        (flexItem_6 = createElement(
          'div',
          {
            class: 'flex-item',
            style: {
              display: 'inline-block',
              width: '50px',
              height: '50px',
              margin: '20px 20px',
              background: '#eee',
              'line-height': '50px',
              'text-align': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`2`)]
        )),
        (flexItem_7 = createElement(
          'div',
          {
            class: 'flex-item',
            style: {
              display: 'inline-block',
              width: '50px',
              height: '50px',
              margin: '20px 20px',
              background: '#eee',
              'line-height': '50px',
              'text-align': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1`)]
        )),
      ]
    );
    flexContainer_2 = createElement(
      'div',
      {
        class: 'flex-container flex-direction-column',
        style: {
          display: 'block',
          margin: '20px',
          background: '#333',
          'line-height': '0px',
          padding: '20px 0px',
          'box-sizing': 'border-box',
        },
      },
      [
        (flexItem_8 = createElement(
          'div',
          {
            class: 'flex-item first',
            style: {
              display: 'block',
              width: '50px',
              height: '50px',
              margin: '40px 20px',
              background: '#eee',
              'line-height': '50px',
              'text-align': 'center',
              'margin-top': '0px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1`)]
        )),
        (flexItem_9 = createElement(
          'div',
          {
            class: 'flex-item',
            style: {
              display: 'block',
              width: '50px',
              height: '50px',
              margin: '40px 20px',
              background: '#eee',
              'line-height': '50px',
              'text-align': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`2`)]
        )),
        (flexItem_10 = createElement(
          'div',
          {
            class: 'flex-item',
            style: {
              display: 'block',
              width: '50px',
              height: '50px',
              margin: '40px 20px',
              background: '#eee',
              'line-height': '50px',
              'text-align': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`3`)]
        )),
        (flexItem_11 = createElement(
          'div',
          {
            class: 'flex-item last',
            style: {
              display: 'block',
              width: '50px',
              height: '50px',
              margin: '40px 20px',
              background: '#eee',
              'line-height': '50px',
              'text-align': 'center',
              'margin-bottom': '0px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`new`)]
        )),
      ]
    );
    flexContainer_3 = createElement(
      'div',
      {
        class: 'flex-container flex-direction-column-reverse',
        style: {
          display: 'block',
          margin: '20px',
          background: '#333',
          'line-height': '0px',
          padding: '20px 0px',
          'box-sizing': 'border-box',
        },
      },
      [
        (flexItem_12 = createElement(
          'div',
          {
            class: 'flex-item first',
            style: {
              display: 'block',
              width: '50px',
              height: '50px',
              margin: '40px 20px',
              background: '#eee',
              'line-height': '50px',
              'text-align': 'center',
              'margin-top': '0px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`new`)]
        )),
        (flexItem_13 = createElement(
          'div',
          {
            class: 'flex-item',
            style: {
              display: 'block',
              width: '50px',
              height: '50px',
              margin: '40px 20px',
              background: '#eee',
              'line-height': '50px',
              'text-align': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`3`)]
        )),
        (flexItem_14 = createElement(
          'div',
          {
            class: 'flex-item',
            style: {
              display: 'block',
              width: '50px',
              height: '50px',
              margin: '40px 20px',
              background: '#eee',
              'line-height': '50px',
              'text-align': 'center',
              'box-sizing': 'border-box',
            },
          },
          [createText(`2`)]
        )),
        (flexItem_15 = createElement(
          'div',
          {
            class: 'flex-item last',
            style: {
              display: 'block',
              width: '50px',
              height: '50px',
              margin: '40px 20px',
              background: '#eee',
              'line-height': '50px',
              'text-align': 'center',
              'margin-bottom': '0px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1`)]
        )),
      ]
    );
    BODY.appendChild(flexContainer);
    BODY.appendChild(flexContainer_1);
    BODY.appendChild(flexContainer_2);
    BODY.appendChild(flexContainer_3);

    await snapshot();
  });
  it("column-overlap-001", async () => {
    let p;
    let relpos;
    let flex;
    let layoutColumn;
    let layoutRow;
    let container;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `XXX and YYY should be on separate lines and not overlap, i.e. the height of .flex should not be 0.`
        ),
      ]
    );
    container = createElement(
      'div',
      {
        class: 'layout-column',
        id: 'container',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          'box-sizing': 'border-box',
        },
      },
      [
        (layoutRow = createElement(
          'div',
          {
            class: 'layout-row',
            style: {
              display: 'flex',
              'box-sizing': 'border-box',
            },
          },
          [
            (layoutColumn = createElement(
              'div',
              {
                class: 'layout-column',
                style: {
                  display: 'flex',
                  'flex-direction': 'column',
                  'box-sizing': 'border-box',
                },
              },
              [
                (flex = createElement(
                  'div',
                  {
                    class: 'flex',
                    'data-expected-height': '18',
                    style: {
                      flex: '1',
                      'min-height': '0',
                      'box-sizing': 'border-box',
                    },
                  },
                  [
                    createText(`XXX`),
                    (relpos = createElement('span', {
                      id: 'relpos',
                      style: {
                        position: 'relative',
                        top: '1px',
                        'box-sizing': 'border-box',
                      },
                    })),
                  ]
                )),
                createElement(
                  'div',
                  {
                    style: {
                      'box-sizing': 'border-box',
                    },
                  },
                  [createText(`YYY`)]
                ),
              ]
            )),
          ]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(container);

    await snapshot();
  });

  it("row-001-visual", async () => {
    let p;
    let test01;
    let test02;
    let test03;
    let test;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if:`),

        createText(`
      1. the rectangle 1, 2, 3 show up in a row in a red rectangle and no gap between them.`),

        createText(`
      2. the rectangle 1, 2, 3 appear in upper left of red rectangle.`),
      ]
    );
    test = createElement(
      'div',
      {
        id: 'test',
        style: {
          background: '#ff0000',
          height: '200px',
          width: '200px',
          display: 'flex',
          'flex-direction': 'row',
          'box-sizing': 'border-box',
        },
      },
      [
        (test01 = createElement(
          'div',
          {
            id: 'test01',
            style: {
              width: '50px',
              height: '50px',
              'text-align': 'center',
              'font-size': '20px',
              background: '#7FFF00',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1`)]
        )),
        (test02 = createElement(
          'div',
          {
            id: 'test02',
            style: {
              width: '50px',
              height: '50px',
              'text-align': 'center',
              'font-size': '20px',
              background: '#00FFFF',
              'box-sizing': 'border-box',
            },
          },
          [createText(`2`)]
        )),
        (test03 = createElement(
          'div',
          {
            id: 'test03',
            style: {
              width: '50px',
              height: '50px',
              'text-align': 'center',
              'font-size': '20px',
              background: '#4169E1',
              'box-sizing': 'border-box',
            },
          },
          [createText(`3`)]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(test);


    await snapshot();
  });
  it("row-reverse-001-visual", async () => {
    let p;
    let test01;
    let test02;
    let test03;
    let test;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if:`),

        createText(`
    1. the rectangle 1, 2, 3 show up in a row in a red rectangle and no gap between them.`),

        createText(`
    2. the rectangle 1, 2, 3 appear in upper right of red rectangle and from left to right of the row: 3, 2, 1.`),
      ]
    );
    test = createElement(
      'div',
      {
        id: 'test',
        style: {
          background: '#ff0000',
          height: '200px',
          width: '200px',
          display: 'flex',
          'flex-direction': 'row-reverse',
          'box-sizing': 'border-box',
        },
      },
      [
        (test01 = createElement(
          'div',
          {
            id: 'test01',
            style: {
              width: '50px',
              height: '50px',
              'text-align': 'center',
              'font-size': '20px',
              background: '#7FFF00',
              'box-sizing': 'border-box',
            },
          },
          [createText(`1`)]
        )),
        (test02 = createElement(
          'div',
          {
            id: 'test02',
            style: {
              width: '50px',
              height: '50px',
              'text-align': 'center',
              'font-size': '20px',
              background: '#00FFFF',
              'box-sizing': 'border-box',
            },
          },
          [createText(`2`)]
        )),
        (test03 = createElement(
          'div',
          {
            id: 'test03',
            style: {
              width: '50px',
              height: '50px',
              'text-align': 'center',
              'font-size': '20px',
              background: '#4169E1',
              'box-sizing': 'border-box',
            },
          },
          [createText(`3`)]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(test);


    await snapshot();
  });
});
