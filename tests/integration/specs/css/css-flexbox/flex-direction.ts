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

    await matchViewportSnapshot();
  });
  xit('with-element-insert', async () => {
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

    await matchViewportSnapshot();
  });
});
