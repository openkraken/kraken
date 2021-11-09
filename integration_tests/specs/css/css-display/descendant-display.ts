describe('descendant-display', () => {
  it('none-001', async () => {
    let divStyle = {
      display: 'none',
    };
    let childStyle = {
      backgroundColor: 'red',
      width: '100px',
      height: '100px',
    };
    let element = createElementWithStyle('div', divStyle, [
      createElementWithStyle('div', {
        ...divStyle,
        ...childStyle,
      }),
    ]);
    append(BODY, element);
    await snapshot();
  });

  it('override-001', async () => {
    let divStyle = {
      display: 'none',
    };
    let childStyle = {
      backgroundColor: 'red',
      display: 'block',
      width: '100px',
      height: '100px',
    };
    let element = createElementWithStyle('div', divStyle, [
      createElementWithStyle('div', {
        ...divStyle,
        ...childStyle,
      }),
    ]);
    append(BODY, element);
    await snapshot();
  });
});
