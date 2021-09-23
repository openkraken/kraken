/*auto generated*/
describe('css-flexbox', () => {
  it('img-expand-evenly', async () => {
    let p;
    let flexbox;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`3 rectangular images fill out border.`)]
    );
    flexbox = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          height: '50px',
          width: '300px',
          border: '2px solid black',
          display: 'flex',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          src: 'assets/solidblue.png',
          style: {
            width: '48px',
            'flex-grow': '1',
            background: 'purple',
            border: '1px solid white',
            'box-sizing': 'border-box',
          },
        }),
        createElement('img', {
          src: 'assets/solidblue.png',
          style: {
            width: '48px',
            'flex-grow': '1',
            background: 'purple',
            border: '1px solid white',
            'box-sizing': 'border-box',
          },
        }),
        createElement('img', {
          src: 'assets/solidblue.png',
          style: {
            width: '48px',
            'flex-grow': '1',
            background: 'purple',
            border: '1px solid white',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexbox);

    await snapshot(0.5);
  });
  it('row-ref', async () => {
    let p;
    let item;
    let item_1;
    let item_2;
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
          `The test passes if you see a tall green box with pairs of the 1-9 and a-i listed top to bottom in two columns.`
        ),
      ]
    );
    container = createElement(
      'div',
      {
        class: 'container',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        (item = createElement(
          'div',
          {
            class: 'item',
            style: {
              color: 'white',
              'background-color': 'green',
              height: '100px',
              width: '100px',
              'line-height': '15px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`１２３ａｂｃ`)]
        )),
        (item_1 = createElement(
          'div',
          {
            class: 'item',
            style: {
              color: 'white',
              'background-color': 'green',
              height: '100px',
              width: '100px',
              'line-height': '15px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`４５６ｄｅｆ`)]
        )),
        (item_2 = createElement(
          'div',
          {
            class: 'item',
            style: {
              color: 'white',
              'background-color': 'green',
              height: '100px',
              width: '100px',
              'line-height': '15px',
              'box-sizing': 'border-box',
            },
          },
          [createText(`７８９ｇｈｉ`)]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(container);

    await snapshot();
  });

  it('img-expand-evenly-ref', async () => {
    let p;
    let flexbox;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`3 rectangular images fill out border.`)]
    );
    flexbox = createElement(
      'div',
      {
        class: 'flexbox',
        style: {
          height: '50px',
          width: '300px',
          border: '2px dotted black',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('img', {
          src: 'assets/solidblue.png',
          style: {
            width: '98px',
            height: '48px',
            background: 'purple',
            border: '1px solid white',
            'box-sizing': 'border-box',
          },
        }),
        createElement('img', {
          src: 'assets/solidblue.png',
          style: {
            width: '98px',
            height: '48px',
            background: 'purple',
            border: '1px solid white',
            'box-sizing': 'border-box',
          },
        }),
        createElement('img', {
          src: 'assets/solidblue.png',
          style: {
            width: '98px',
            height: '48px',
            background: 'purple',
            border: '1px solid white',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexbox);

    await snapshot(0.1);
  });
});
