/*auto generated*/
describe('abspos-013', () => {
  it('ref', async () => {
    let div;
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'background-color': 'green',
          color: 'white',
          height: '64px',
          width: '320px',
        },
      },
      [createText(`This block should be green.`)]
    );
    BODY.appendChild(div);

    await snapshot();
  });
});
