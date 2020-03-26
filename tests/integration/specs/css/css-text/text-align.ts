describe('Text TextAlign', () => {
  const TEXT_ALIGN = [
    'start',
    'end',
    'left',
    'right',
    'center',
    'justify',
    'match-parent',
    'justify-all',
  ];

  TEXT_ALIGN.forEach(value => {
    it(`should work with ${value}`, () => {
      const cont = create(
        'div',
        {
          margin: '10px',
          border: '1px solid #000',
          textAlign: value,
        },
        [
          createText(`These text should align ${value}.`),
          createText('Sibling child.'),
        ]
      );
      append(BODY, cont);

      return matchElementImageSnapshot(cont);
    });
  });
});
