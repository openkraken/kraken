describe('Text TextDecoration', () => {
  const TEXT_SHADOW = [
    '3px 3px rgba(0,0,0,.3)',
    '4px 4px 4px rgba(0,0,0,.3)',
    '3px 3px 0 rgba(255,255,255,1),3px 3px 2px rgba(0,85,0,.8)',
  ];

  TEXT_SHADOW.forEach(value => {
    // Merged property.
    it(`should work with text-shadow=${value}`, () => {
      const cont = createElementWithStyle(
        'div',
        {
          margin: '10px',
          border: '1px solid #000',
          textShadow: `${value}`,
        },
        [
          createText(`These text should be text-shadow: ${value}.`),
          createText('文字阴影'),
        ]
      );
      append(BODY, cont);

      return snapshot(cont);
    });
  });
});
