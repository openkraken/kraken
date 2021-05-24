
describe('Font', () => {
  it('shorthand', () => {
    const p1 = createElementWithStyle(
      'p',
      {
        font: '12px "sans-serif"',
      },
      createText('font: 12px "sans-serif"')
    );
    
    const p2 = createElementWithStyle(
      'p',
      {
        font: 'italic 14px serif',
      },
      createText('font: italic 22px serif')
    );
    
    const p3 = createElementWithStyle(
      'p',
      {
        font: 'italic bold 16px/2 cursive',
      },
      createText('font: italic bold 16px/2 cursive')
    );
    
    const p4 = createElementWithStyle(
      'p',
      {
        font: 'normal 600 18px fantasy',
      },
      createText('font: normal 600 18px fantasy')
    );
    
    const p5 = createElementWithStyle(
      'p',
      {
        font: 'italic 20px monospace',
      },
      createText('font: italic 20px monospace')
    );
    
    append(BODY, p1);
    append(BODY, p2);
    append(BODY, p3);
    append(BODY, p4);
    append(BODY, p5);

    return snapshot();
  });
});
