xdescribe('Text TextIndent', () => {
  const TEXT_INDENT = ['normal', '-5px', 0, '10px'];

  TEXT_INDENT.forEach(value => {
    it(`should work with ${value}`, () => {
      const cont = createElementWithStyle(
        'div',
        {
          margin: '10px',
          border: '1px solid #000',
          textIndent: value,
        },
        createText(`These text should be text-indent: ${value}.`)
      );
      append(BODY, cont);

      return snapshot(cont);
    });
  });
});
