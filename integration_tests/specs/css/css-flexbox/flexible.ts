/*auto generated*/
describe('Flexible', () => {
  it('order', async () => {
    let red;
    let blue;
    let black;
    let box;
    box = createElement(
      'div',
      {
        style: {
          margin: '0 auto',
          'background-color': '#CCC',
          'border-radius': '5px',
          width: '300px',
          display: 'flex',
          'flex-flow': 'row',
          'box-sizing': 'border-box',
        },
      },
      [
        (red = createElement(
          'div',
          {
            style: {
              'text-align': 'center',
              flex: '0 1 auto',
              width: '200px',
              'background-color': '#F00',
              'box-sizing': 'border-box',
            },
          },
          [createText(`A`)]
        )),
        (blue = createElement(
          'div',
          {
            style: {
              'text-align': 'center',
              flex: '0 1 auto',
              width: '200px',
              'background-color': '#00F',
              'box-sizing': 'border-box',
            },
          },
          [createText(`B`)]
        )),
        (black = createElement(
          'div',
          {
            style: {
              'text-align': 'center',
              flex: '0 1 auto',
              width: '200px',
              'background-color': '#000',
              color: '#FFF',
              'box-sizing': 'border-box',
            },
          },
          [createText(`C`)]
        )),
      ]
    );
    BODY.appendChild(box);

    await snapshot();
  });
});
