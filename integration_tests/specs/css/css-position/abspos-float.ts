/*auto generated*/
describe('abspos-float', () => {
  it('with-inline-container-ref', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if there is green square.`)]
    );
    div = createElement('div', {
      style: {
        width: '100px',
        height: '100px',
        background: 'green',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });
});
