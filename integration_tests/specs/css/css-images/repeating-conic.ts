/*auto generated*/
describe('repeating-conic', () => {
  xit('gradient-ref', async () => {
    let gradient;
    gradient = createElement('div', {
      id: 'gradient',
      style: {
        width: '200px',
        height: '200px',
        'background-image':
          'conic-gradient(black 25%, white 0 50%, black 0 75%, white 0)',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(gradient);

    await snapshot();
  });
  xit('gradient', async () => {
    let gradient;
    gradient = createElement('div', {
      id: 'gradient',
      style: {
        width: '200px',
        height: '200px',
        'background-color': 'red',
        'background-image':
          'repeating-conic-gradient(black 0 25%, white 25% 50%)',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(gradient);

    await snapshot();
  });
});
