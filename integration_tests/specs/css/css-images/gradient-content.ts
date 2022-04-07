/*auto generated*/
describe('gradient-content', () => {
  // @TODO: repeating-linear-gradient with percentage impl differs from browser.
  xit('box-ref', async () => {
    let x;
    x = createElement('div', {
      id: 'x',
      style: {
        width: '200px',
        height: '200px',
        border: '40px',
        'border-style': 'solid',
        'border-color': 'transparent',
        'background-image':
          'repeating-linear-gradient(to bottom right, white, black, white 30px)',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(x);

    await snapshot();
  });
  // @TODO: repeating-linear-gradient with percentage impl differs from browser.
  xit('box', async () => {
    let x;
    x = createElement('div', {
      id: 'x',
      style: {
        'background-origin': 'content-box',
        width: '200px',
        height: '200px',
        padding: '40px',
        'background-image':
          'repeating-linear-gradient(to bottom right, white, black, white 30px)',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(x);

    await snapshot();
  });
});
