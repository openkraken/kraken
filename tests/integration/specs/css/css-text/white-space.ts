describe('Text WhiteSpace', () => {
  it('should work with basic example', () => {
    // default to normal
    document.body.appendChild(
      document.createTextNode('\n there should \t\n\r be  no\n')
    );
    document.body.appendChild(document.createTextNode(' new line'));

    return matchScreenshot();
  });

  it('should work with default value', () => {

    const cont = createElement(
      'div',
      {
        width: '100px',
        backgroundColor: '#f40',
      },
      [
        createText('\n there should \t\n\r be\n new line'),
      ]
    );

    append(BODY, cont);

    return matchScreenshot();
  });

  it('should work with normal', () => {

    const cont = createElement(
      'div',
      {
        width: '100px',
        backgroundColor: '#f40',
        whiteSpace: 'normal',
      },
      [
        createText('\n there should \t\n\r be\n new line'),
      ]
    );

    append(BODY, cont);

    return matchScreenshot();
  });

  it('should work with no-wrap', () => {

    const cont = createElement(
      'div',
      {
        width: '100px',
        backgroundColor: '#f40',
        whiteSpace: 'nowrap',
      },
      [
        createText('\n there should \t\n\r be\n no new line'),
      ]
    );

    append(BODY, cont);

    return matchScreenshot();
  });
});
