/*auto generated*/
describe('gradient-button', () => {
  it('ref', async () => {
    let button;
    button = createElement('div', {
      id: 'button',
      style: {
        width: '360px',
        height: '120px',
        background: 'linear-gradient(blue, green)',
        'border-width': '5px',
        'border-style': 'solid',
        'border-color': 'red',
        'border-radius': '10px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(button);

    await snapshot();
  });
});
