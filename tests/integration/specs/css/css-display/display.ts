describe('display', () => {
  it('001', async () => {
    let divStyle = {
      display: 'inline',
    };
    let element = create('div', {}, [
      create('div', divStyle, createText('Filter text')),
      create('div', divStyle, createText('Filter text')),
    ]);
    append(BODY, element);
    await matchScreenshot();
  });

  it('002', async () => {
    let divStyle = {
      display: 'block',
    };
    let element = create('div', {}, [
      create('div', divStyle, createText('Filter text')),
      create('div', divStyle, createText('Filter text')),
    ]);
    append(BODY, element);
    await matchScreenshot();
  });
  it('005', async () => {
    let divdivStyle = {
      display: 'inline-block',
    };
    let element = create('div', {}, [
      createText('Filter text'),
      create('div', divdivStyle, createText('Filter text')),
    ]);
    append(BODY, element);
    await matchScreenshot();
  });
  it('016', async () => {
    let divStyle = {
      color: 'red',
      display: 'none',
    };
    let element = create('div', divStyle, createText('FAIL'));
    append(BODY, element);
    await matchScreenshot();
  });
  it('applies-to-001', async () => {
    let spanStyle = {
      display: 'inline',
    };
    let element = create('div', {}, [
      createText('Filter text'),
      create('span', spanStyle, createText('Filter Text')),
      createText('Filter text'),
    ]);
    append(BODY, element);
    await matchScreenshot();
  });
  it('none-001', async () => {
    let divStyle = {
      backgroundColor: 'red',
      display: 'none',
      position: 'absolute',
    };
    let element = create('div', divStyle, createText('Filter Text'));
    append(BODY, element);
    await matchScreenshot();
  });
  it('none-002', async () => {
    let divStyle = {
      backgroundColor: 'red',
      display: 'none',
      position: 'fixed',
    };
    let element = create('div', divStyle, createText('Filter Text'));
    append(BODY, element);
    await matchScreenshot();
  });
});
