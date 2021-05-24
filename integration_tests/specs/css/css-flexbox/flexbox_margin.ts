/*auto generated*/
describe('flexbox_margin', () => {
  it('auto', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          margin: '10px 0',
          border: '1px solid black',
          height: '80px',
          width: '320px',
          position: 'relative',
          display: 'flex',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              background: 'white',
              margin: '10px auto',
              width: '40px',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`one`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'white',
              margin: '10px auto',
              width: '40px',
              display: 'inline-block',
              'box-sizing': 'border-box',
            },
          },
          [createText(`two`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
  it('ref', async () => {
    let div;
    div = createElement('div', {
      style: {
        background: 'black',
        margin: '10px',
        height: '40px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(div);

    await snapshot();
  });
  it('', async () => {
    let div;
    div = createElement('div', {
      style: {
        background: 'black',
        margin: '10px',
        height: '40px',
        display: 'flex',
        'justify-content': 'space-around',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(div);

    await snapshot();
  });
});
