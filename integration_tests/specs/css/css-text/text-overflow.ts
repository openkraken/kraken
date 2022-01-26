describe('Text Overflow', () => {
  it('should work with default value with overflow no visible', () => {
    const cont = createElementWithStyle(
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

    return snapshot();
  });

  it('should work with clip with overflow no visible', () => {

    const cont = createElementWithStyle(
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

    return snapshot();
  });

  it('should not work with clip with overflow visible', () => {

    const cont = createElementWithStyle(
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

    return snapshot();
  });

  it('should work with ellipsis when overflow not visible and whiteSpace nowrap', () => {

    const cont = createElementWithStyle(
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

    return snapshot();
  });

  it('should work with empty string', () => {
    const cont = createElementWithStyle(
      'div',
      {
        width: '50px',
        backgroundColor: '#f40',
        overflow: 'hidden',
        whiteSpace: 'nowrap',
        textOverflow: ''
      },
      [
        createText('text is cliped'),
      ]
    );

    append(BODY, cont);

    return snapshot();
  });

  it('should not work with ellipsis when overflow visible', () => {

    const cont = createElementWithStyle(
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

    return snapshot();
  });

  it('should not work with ellipsis when whiteSpace normal', () => {

    const cont = createElementWithStyle(
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

    return snapshot();
  });

  it('should work with text-overflow: ellipsis', async () => {
    const container0 = document.createElement('div');
    setElementStyle(container0, {
      width: '300px',
      height: '300px',
      display: 'flex',
      backgroundColor: '#aaa',
      flexDirection: 'row',
      alignItems: 'stretch',
    });

    document.body.appendChild(container0);

    const container = document.createElement('div');
    setElementStyle(container, {
      width: '200px',
      display: 'flex',
      backgroundColor: '#666',
      flexDirection: 'row',
      alignItems: 'stretch',
    });

    container0.appendChild(container);

    const child1 = document.createElement('div');
    setElementStyle(child1, {
      width: '50px',
      backgroundColor: 'blue',
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      whiteSpace: 'nowrap'
    });
    container.appendChild(child1);
    child1.appendChild(document.createTextNode('block with no height'));

    await snapshot();
  });

  it('should works with ellipsis of one line and lineHeight exists', () => {
    const cont = createElementWithStyle(
      'div',
      {
        width: '80px',
        backgroundColor: '#f40',
        overflow: 'hidden',
        whiteSpace: 'nowrap',
        textOverflow: 'ellipsis',
      },
      [
        createText('text with ellipsis in one lines'),
      ]
    );

    append(BODY, cont);

    return snapshot();
  });

  it('should works with ellipsis of two line and lineHeight exists', () => {
    const cont = createElementWithStyle(
      'div',
      {
        width: '80px',
        backgroundColor: '#f40',
        overflow: 'hidden',
        lineClamp: 2,
        textOverflow: 'ellipsis',
      },
      [
        createText('text with ellipsis in two lines'),
      ]
    );

    append(BODY, cont);

    return snapshot();
  });
});
