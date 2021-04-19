/*auto generated*/
describe('flexbox-flex', () => {
  it('wrap-default', async () => {
    let p;
    let green;
    let flexWrapper;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`The test passes if there is a green square and no red.`)]
    );
    flexWrapper = createElement(
      'div',
      {
        class: 'flex-wrapper',
        style: {
          display: 'flex',
          background: 'green',
          'border-right': '60px solid red',
          width: '60px',
          height: '120px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            width: '60px',
            flex: 'none',
            'box-sizing': 'border-box',
          },
        }),
        (green = createElement('div', {
          class: 'green',
          style: {
            width: '60px',
            flex: 'none',
            background: 'green',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexWrapper);

    await snapshot();
  });
  it('wrap-flexing-ref', async () => {
    let p;
    let container;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if there is a green rectangle and no red.`)]
    );
    container = createElement('div', {
      class: 'container',
      style: {
        width: '150px',
        height: '100px',
        background: 'green',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(container);

    await snapshot();
  });
  it('wrap-flexing', async () => {
    let p;
    let item;
    let item_1;
    let container;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if there is a green rectangle and no red.`)]
    );
    container = createElement(
      'div',
      {
        class: 'container',
        style: {
          display: 'flex',
          width: '150px',
          height: '100px',
          'flex-wrap': 'wrap',
          background: 'red',
          'box-sizing': 'border-box',
        },
      },
      [
        (item = createElement('div', {
          class: 'item',
          style: {
            'min-width': '100px',
            flex: '1',
            height: '50px',
            display: 'inline-block',
            background: 'green',
            'box-sizing': 'border-box',
          },
        })),
        (item_1 = createElement('div', {
          class: 'item',
          style: {
            'min-width': '100px',
            flex: '1',
            height: '50px',
            display: 'inline-block',
            background: 'green',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(container);

    await snapshot();
  });
  it('wrap-nowrap', async () => {
    let p;
    let green;
    let flexWrapper;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`The test passes if there is a green square and no red.`)]
    );
    flexWrapper = createElement(
      'div',
      {
        class: 'flex-wrapper',
        style: {
          display: 'flex',
          'flex-wrap': 'nowrap',
          background: 'green',
          'border-right': '60px solid red',
          width: '60px',
          height: '120px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            width: '60px',
            flex: 'none',
            'box-sizing': 'border-box',
          },
        }),
        (green = createElement('div', {
          class: 'green',
          style: {
            width: '60px',
            flex: 'none',
            background: 'green',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexWrapper);

    await snapshot();
  });
});
