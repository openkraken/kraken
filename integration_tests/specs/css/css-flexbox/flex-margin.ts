/*auto generated*/
describe('flex-margin', () => {
  it('no-collapse', async () => {
    let p;
    let redBox;
    let box1;
    let box2;
    let container;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`The test passes if there are two green boxes and no red.`)]
    );
    redBox = createElement('div', {
      id: 'red-box',
      style: {
        position: 'absolute',
        top: '350px',
        left: '10px',
        width: '100px',
        height: '100px',
        'background-color': 'red',
        'box-sizing': 'border-box',
      },
    });
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          position: 'absolute',
          top: '100px',
          left: '10px',
          width: '200px',
          height: '300px',
          'box-sizing': 'border-box',
        },
      },
      [
        (box1 = createElement('div', {
          id: 'box1',
          class: 'box',
          style: {
            width: '100px',
            height: '100px',
            'background-color': 'green',
            flex: 'none',
            margin: '50px 0',
            'box-sizing': 'border-box',
          },
        })),
        (box2 = createElement('div', {
          id: 'box2',
          class: 'box',
          style: {
            width: '100px',
            height: '100px',
            'background-color': 'green',
            flex: 'none',
            margin: '50px 0',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(redBox);
    BODY.appendChild(container);

    await snapshot();
  });
});
