/*auto generated*/
describe('conic-gradient', () => {
  it('angle-negative', async () => {
    let gradient;
    gradient = createElement('div', {
      id: 'gradient',
      style: {
        width: '200px',
        height: '200px',
        'background-image':
          'conic-gradient(from -90deg, blue 0 25%, black 25% 50%, red 50% 75%, green 75% 100%)',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(gradient);

    await snapshot();
  });
  it('angle', async () => {
    let gradient;
    gradient = createElement('div', {
      id: 'gradient',
      style: {
        width: '200px',
        height: '200px',
        'background-image':
          'conic-gradient(from 90deg, red 0 25%, green 25% 50%, blue 50% 75%, black 75% 100%)',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(gradient);

    await snapshot();
  });
  it('center-ref', async () => {
    let top;
    let bottom;
    let box;
    box = createElement(
      'div',
      {
        id: 'box',
        style: {
          width: '200px',
          height: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        (top = createElement('div', {
          id: 'top',
          style: {
            'border-left': '50px solid black',
            'border-right': '150px solid red',
            height: '50px',
            'box-sizing': 'border-box',
          },
        })),
        (bottom = createElement('div', {
          id: 'bottom',
          style: {
            'border-left': '50px solid blue',
            'border-right': '150px solid green',
            height: '150px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(box);

    await snapshot();
  });

  // @TODO: The display of multiple conic-gradient differs from browser.
  xit('center', async () => {
    let gradient;
    gradient = createElement('div', {
      id: 'gradient',
      style: {
        width: '200px',
        height: '200px',
        'background-image':
          'conic-gradient(at 25% 25%, red 0 25%, green 25% 50%, blue 50% 75%, black 75% 100%)',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(gradient);

    await snapshot();
  });
});
