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
      const cont = createElementWithStyle(
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

      return snapshot(cont);
    });
  });

  it('should work with flex-shrink', async () => {
    const cont = createElement(
      'div',
      {style: {
        display: 'flex',
        width: '200px',
        height: '100px',
        border: '1px solid #000',
      }},
      [
        createElement('div', {
          style: {
            flexShrink: 1,
            width: '400px',
            height: '50px',
            backgroundColor: 'green',
            textAlign: 'center',
          }
        }, [
          createText('center')
        ])
      ]
    );
    document.body.appendChild(cont);

    await snapshot();

  });

  it('should work with flex-grow', async () => {
    const cont = createElement(
      'div',
      {style: {
        display: 'flex',
        width: '200px',
        height: '100px',
        border: '1px solid #000',
      }},
      [
        createElement('div', {
          style: {
            flexGrow: 1,
            width: '50px',
            height: '50px',
            backgroundColor: 'green',
            textAlign: 'center',
          }
        }, [
          createText('center')
        ])
      ]
    );
    document.body.appendChild(cont);

    await snapshot();

  });
});
