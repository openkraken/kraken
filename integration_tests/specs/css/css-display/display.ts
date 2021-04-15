describe('display', () => {
  it('001', async () => {
    let divStyle = {
      display: 'inline',
    };
    let element = createElementWithStyle('div', {}, [
      createElementWithStyle('div', divStyle, createText('Filter text')),
      createElementWithStyle('div', divStyle, createText('Filter text')),
    ]);
    append(BODY, element);
    await snapshot();
  });

  it('002', async () => {
    let divStyle = {
      display: 'block',
    };
    let element = createElementWithStyle('div', {}, [
      createElementWithStyle('div', divStyle, createText('Filter text')),
      createElementWithStyle('div', divStyle, createText('Filter text')),
    ]);
    append(BODY, element);
    await snapshot();
  });
  it('005', async () => {
    let divdivStyle = {
      display: 'inline-block',
    };
    let element = createElementWithStyle('div', {}, [
      createText('Filter text'),
      createElementWithStyle('div', divdivStyle, createText('Filter text')),
    ]);
    append(BODY, element);
    await snapshot();
  });
  it('016', async () => {
    let divStyle = {
      color: 'red',
      display: 'none',
    };
    let element = createElementWithStyle('div', divStyle, createText('FAIL'));
    append(BODY, element);
    await snapshot();
  });
  it('applies-to-001', async () => {
    let spanStyle = {
      display: 'inline',
    };
    let element = createElementWithStyle('div', {}, [
      createText('Filter text'),
      createElementWithStyle('span', spanStyle, createText('Filter Text')),
      createText('Filter text'),
    ]);
    append(BODY, element);
    await snapshot();
  });
  it('none-001', async () => {
    let divStyle = {
      backgroundColor: 'red',
      display: 'none',
      position: 'absolute',
    };
    let element = createElementWithStyle('div', divStyle, createText('Filter Text'));
    append(BODY, element);
    await snapshot();
  });
  it('none-002', async () => {
    let divStyle = {
      backgroundColor: 'red',
      display: 'none',
      position: 'fixed',
    };
    let element = createElementWithStyle('div', divStyle, createText('Filter Text'));
    append(BODY, element);
    await snapshot();
  });
});
