describe('descendant-display', () => {
  it('none-001', async () => {
    let divStyle = {
      display: 'none',
    };
    let divDivStyle = {
      backgroundColor: 'red',
      width: '100px',
      height: '100px',
    };
    let element = createElement('div', divStyle, [
      createElement('div', {
        ...divStyle,
        ...divDivStyle,
      }),
    ]);
    append(BODY, element);
    await matchScreenshot();
  });

  it('override-001', async () => {
    let divStyle = {
      display: 'none',
    };
    let divdivStyle = {
      backgroundColor: 'red',
      display: 'block',
      width: '100px',
      height: '100px',
    };
    let element = createElement('div', divStyle, [
      createElement('div', {
        ...divStyle,
        ...divdivStyle,
      }),
    ]);
    append(BODY, element);
    await matchScreenshot();
  });
});
