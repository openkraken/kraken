/*auto generated*/
describe('blocks-018', () => {
  xit('ref', async () => {
    let div;
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'line-height': '1',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              'background-color': 'green',
              color: 'white',
            },
          },
          [createText(`Test passes if there is no red.`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
});
