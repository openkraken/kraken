/*auto generated*/
describe('css-box', () => {
  it('justify-content', async () => {
    let p;
    let item;
    let item_1;
    let item_2;
    let item_3;
    let item_4;
    let flexbox;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `This test passes if the DIV5's position in the end and the div is Horizontal layout`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          'background-color': 'green',
          width: '300px',
          height: '40px',
          display: 'flex',
          'flex-flow': 'row',
          'justify-content': 'flex-end',
          'box-sizing': 'border-box',
        },
      },
      [
        (item = createElement(
          'div',
          {
            class: 'item',
            style: {
              width: '50px',
              height: '30px',
              'box-sizing': 'border-box',
              'background-color': 'rgb(242, 210, 80)',
              color: 'rgb(41, 119, 248)',
            },
          },
          [createText(`DIV1`)]
        )),
        (item_1 = createElement(
          'div',
          {
            class: 'item',
            style: {
              width: '50px',
              height: '30px',
              'box-sizing': 'border-box',
              'background-color': 'rgb(110, 8, 7)',
              color: 'rgb(162, 152, 22)',
            },
          },
          [createText(`DIV2`)]
        )),
        (item_2 = createElement(
          'div',
          {
            class: 'item',
            style: {
              width: '50px',
              height: '30px',
              'box-sizing': 'border-box',
              'background-color': 'rgb(215, 172, 243)',
              color: 'rgb(74, 123, 110)',
            },
          },
          [createText(`DIV3`)]
        )),
        (item_3 = createElement(
          'div',
          {
            class: 'item',
            style: {
              width: '50px',
              height: '30px',
              'box-sizing': 'border-box',
              'background-color': 'rgb(242, 133, 80)',
              color: 'rgb(41, 119, 248)',
            },
          },
          [createText(`DIV4`)]
        )),
        (item_4 = createElement(
          'div',
          {
            class: 'item',
            style: {
              width: '50px',
              height: '30px',
              'box-sizing': 'border-box',
              'background-color': 'rgb(242, 50, 80)',
              color: 'rgb(41, 119, 248)',
            },
          },
          [createText(`DIV5`)]
        )),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexbox);

    await snapshot();
  });
});
