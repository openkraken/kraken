/*auto generated*/
describe('infinite-radial', () => {
  it('gradient-crash-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `You should see a 300x300px green square below and no crash.`
        ),
      ]
    );
    div = createElement('div', {
      style: {
        'box-sizing': 'border-box',
        width: '300px',
        height: '300px',
        background: 'green',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
  xit('gradient-refcrash', async () => {
    let p;
    let crash;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `You should see a 300x300px green square below and no crash.`
        ),
      ]
    );
    crash = createElement('div', {
      id: 'crash',
      style: {
        'background-image':
          'repeating-radial-gradient(closest-corner circle at 9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999%, green, green)',
        width: '300px',
        height: '300px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(crash);

    await snapshot();
  });
});
