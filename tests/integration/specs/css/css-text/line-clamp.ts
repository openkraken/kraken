describe('Text LineClamp', () => {
  fit('should work with positive number', () => {
    const cont = createElement(
      'div',
      {
        style: {
          width: '200px',
          lineClamp: 3,
        }
      },
      [
        createText(`hello world hello world hello world hello world hello world hello world hello world`)
      ]
    );
    append(BODY, cont);

    return matchElementImageSnapshot(cont);
  });

  it('should work with none', () => {
    const cont = createElement(
      'div',
      {
        style: {
          width: '200px',
          lineClamp: 'none',
        }
      },
      [
        createText(`hello world hello world hello world hello world hello world hello world hello world`)
      ]
    );
    append(BODY, cont);

    return matchElementImageSnapshot(cont);
  });
});
