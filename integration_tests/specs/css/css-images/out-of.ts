/*auto generated*/
describe('out-of', () => {
  it('range-color-stop-conic', async () => {
    let gradient;
    gradient = createElement('div', {
      id: 'gradient',
      style: {
        width: '200px',
        height: '200px',
        'background-image':
          'conic-gradient(orange -50% -25%, black -25% 25%, red 25% 50%, green 50% 75%, blue 75% 125%, purple 125% 150%)',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(gradient);

    await snapshot();
  });
});
