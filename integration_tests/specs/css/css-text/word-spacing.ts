describe('Text WordSpacing', () => {
  const WORD_SPACING = ['normal', '-5px', 0, '10px'];

  WORD_SPACING.forEach(value => {
    it(`should work with ${value}`, () => {
      const cont = createElementWithStyle(
        'div',
        {
          margin: '10px',
          border: '1px solid #000',
          wordSpacing: value,
        },
        createText(`These text should be word-spacing: ${value}.`)
      );
      append(BODY, cont);

      return snapshot(cont);
    });
  });
});
