/*auto generated*/
describe('tiled-radial', () => {
  // @TODO: radial-gradient with percentage impl differs from browser.
  xit('gradients-ref', async () => {
    let left;
    let right;
    let outer;
    outer = createElement(
      'div',
      {
        id: 'outer',
        style: {
          position: 'absolute',
          width: '600px',
          height: '200px',
          'background-color': 'aquamarine',
          'box-sizing': 'border-box',
        },
      },
      [
        (left = createElement('div', {
          id: 'left',
          style: {
            position: 'absolute',
            width: '300px',
            height: '200px',
            'background-image':
              'radial-gradient(closest-side, red 40%, transparent 40%)',
            left: '80px',
            'box-sizing': 'border-box',
          },
        })),
        (right = createElement('div', {
          id: 'right',
          style: {
            position: 'absolute',
            width: '300px',
            height: '200px',
            'background-image':
              'radial-gradient(closest-side, red 40%, transparent 40%)',
            left: '380px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(outer);

    await snapshot();
  });

  // @TODO: radial-gradient with percentage impl differs from browser.
  xit('gradients', async () => {
    let gradient;
    gradient = createElement('div', {
      id: 'gradient',
      style: {
        position: 'absolute',
        width: '600px',
        height: '200px',
        left: '0px',
        margin: '0px',
        'background-color': 'aquamarine',
        'background-image':
          'radial-gradient(closest-side, red 40%, transparent 40%)',
        'background-size': '300px 200px',
        'background-position': '80px 0px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(gradient);

    await snapshot();
  });
});
