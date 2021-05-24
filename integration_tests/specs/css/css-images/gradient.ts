/*auto generated*/
describe('gradient', () => {
  it('button', async () => {
    let button;
    button = createElement('div', {
      id: 'button',
      style: {
        width: '300px',
        height: '80px',
        padding: '20px 30px',
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
  it('refcrash', async () => {
    let div;
    div = createElement('div', {
      style: {
        background: 'linear-gradient(black 0,white)',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(div);

    await snapshot();
  });
});
