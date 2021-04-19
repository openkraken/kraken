/*auto generated*/
describe('abspos-autopos', () => {
  it('htb-ltr', async () => {
    let flex;
    flex = createElement(
      'div',
      {
        style: {
          display: 'flex',
          position: 'relative',
          width: '100px',
          height: '100px',
          border: '5px solid yellow',
          left: '-20px',
          top: '-5px',
          'background-color': 'red',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            position: 'absolute',
            width: '80px',
            height: '80px',
            'background-color': 'green',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(flex);

    await snapshot();
  });
  it('htb-rtl', async () => {
    let flex;
    flex = createElement(
      'div',
      {
        style: {
          display: 'flex',
          position: 'relative',
          width: '100px',
          height: '100px',
          border: '5px solid yellow',
          left: '-20px',
          top: '-5px',
          'background-color': 'red',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            position: 'absolute',
            width: '80px',
            height: '80px',
            'background-color': 'green',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(flex);

    await snapshot();
  });
});
