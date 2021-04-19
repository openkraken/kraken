describe('Text TextDecoration', () => {
  const TEXT_DECORATION_LINE = [
    'none',
    'underline',
    'overline',
    'line-through',
    // 'blink', // not supported
  ];
  const TEXT_DECORATION_STYLE = ['solid', 'double', 'dotted', 'dashed', 'wavy'];
  const TEXT_DECORATION_COLOR = [
    'red',
    'green',
    '#f4a',
    'rgba(255, 0, 255, 0.5)',
  ];

  TEXT_DECORATION_LINE.forEach(line => {
    TEXT_DECORATION_STYLE.forEach(style => {
      TEXT_DECORATION_COLOR.forEach(color => {
        // Seperated property.
        it(`should work with text-decoration-line=${line}, text-decoration-style=${style}, text-decoration-color=${color}`, () => {
          const cont = createElementWithStyle(
            'div',
            {
              margin: '10px',
              padding: '10px',
              border: '5px solid #000',
              textDecorationLine: line,
              textDecorationStyle: style,
              textDecorationColor: color,
            },
            createText(
              `These text should be text-decoration-line ${line}, text-decoration-style ${style}, text-decoration-color ${color}.`
            )
          );
          append(BODY, cont);

          return snapshot();
        });

        // Merged property.
        it(`should work with text-decoration=${line} ${style} ${color}`, () => {
          const cont = createElementWithStyle(
            'div',
            {
              margin: '10px',
              border: '1px solid #000',
              textDecoration: `${line} ${style} ${color}`,
            },
            createText(
              `These text should be text-decoration: ${line} ${style} ${color}.`
            )
          );
          append(BODY, cont);

          return snapshot();
        });
      });
    });
  });
});
