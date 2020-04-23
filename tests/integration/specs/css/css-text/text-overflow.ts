describe('Text Overflow', () => {
  it('should work with default value with overflow no visible', () => {
    const cont = create(
      'div',
      {
        width: '50px',
        backgroundColor: '#f40',
        overflow: 'hidden',
        whiteSpace: 'nowrap',
      },
      [
        createText('text is cliped'),
      ]
    );

    append(BODY, cont);

    return matchScreenshot();
  });

  it('should work with clip with overflow no visible', () => {

    const cont = create(
      'div',
      {
        width: '50px',
        backgroundColor: '#f40',
        overflow: 'hidden',
        whiteSpace: 'nowrap',
        textOverflow: 'wrap',
      },
      [
        createText('text is cliped'),
      ]
    );

    append(BODY, cont);

    return matchScreenshot();
  });

  it('should not work with clip with overflow visible', () => {

    const cont = create(
      'div',
      {
        width: '50px',
        backgroundColor: '#f40',
        overflow: 'visible',
        whiteSpace: 'nowrap',
        textOverflow: 'wrap',
      },
      [
        createText('text is not cliped'),
      ]
    );

    append(BODY, cont);

    return matchScreenshot();
  });

  it('should work with ellipsis when overflow not visible and whiteSpace nowrap', () => {

    const cont = create(
      'div',
      {
        width: '50px',
        backgroundColor: '#f40',
        overflow: 'hidden',
        whiteSpace: 'nowrap',
        textOverflow: 'ellipsis',
      },
      [
        createText('text is ellipsis'),
      ]
    );

    append(BODY, cont);

    return matchScreenshot();
  });

  it('should not work with ellipsis when overflow visible', () => {

    const cont = create(
      'div',
      {
        width: '50px',
        backgroundColor: '#f40',
        overflow: 'visible',
        whiteSpace: 'normal',
        textOverflow: 'ellipsis',
      },
      [
        createText('text is not ellipsis'),
      ]
    );

    append(BODY, cont);

    return matchScreenshot();
  });

  it('should not work with ellipsis when whiteSpace normal', () => {

    const cont = create(
      'div',
      {
        width: '50px',
        backgroundColor: '#f40',
        overflow: 'hidden',
        whiteSpace: 'normal',
        textOverflow: 'ellipsis',
      },
      [
        createText('text is not ellipsis'),
      ]
    );

    append(BODY, cont);

    return matchScreenshot();
  });
});
