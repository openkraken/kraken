describe('Text LetterSpacing', () => {
  const LETTER_SPACING = ['normal', '-5px', 0, '10px'];

  LETTER_SPACING.forEach(value => {
    it(`should work with ${value}`, () => {
      const cont = createElementWithStyle(
        'div',
        {
          margin: '10px',
          border: '1px solid #000',
          letterSpacing: value,
        },
        createText(`These text should be letter-spacing: ${value}.`)
      );
      append(BODY, cont);

      return snapshot(cont);
    });
  });
});
