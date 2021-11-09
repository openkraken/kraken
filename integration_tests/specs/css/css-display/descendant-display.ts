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
    let element = createElementWithStyle('div', divStyle, [
      createElementWithStyle('div', {
        ...divStyle,
        ...divDivStyle,
      }),
    ]);
    append(BODY, element);
    await snapshot();
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
    let element = createElementWithStyle('div', divStyle, [
      createElementWithStyle('div', {
        ...divStyle,
        ...divdivStyle,
      }),
    ]);
    append(BODY, element);
    await snapshot();
  });
});
