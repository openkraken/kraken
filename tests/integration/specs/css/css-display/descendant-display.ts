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
    let element = create('div', divStyle, [
      create('div', {
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
    let element = create('div', divStyle, [
      create('div', {
        ...divStyle,
        ...divdivStyle,
      }),
    ]);
    append(BODY, element);
    await matchScreenshot();
  });
});
