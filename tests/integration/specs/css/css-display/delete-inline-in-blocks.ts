xdescribe('delete-inline-in-blocks', () => {
  it('beginning-001', async done => {
    let containerStyle = {
      backgroundColor: 'fuchsia',
      color: 'black',
      font: '20px',
      margin: '10px',
    };
    let innerDivStyle = {
      margin: '5px 0',
    };
    let nodeToDeleteStyle = {
      borderLeft: '5px solid yellow',
      borderRight: '5px solid yellow',
    };
    let nodeToDelete = create(
      'span',
      nodeToDeleteStyle,
      createText('Span to remove')
    );
    let container1 = create('div', containerStyle, [
      nodeToDelete,
      create('div', innerDivStyle, createText('First block')),
      createText('\nAnonymous second block\n'),
      create('div', innerDivStyle, createText('Third block')),
    ]);

    async function onClick() {
      container1.removeChild(nodeToDelete);
      await matchScreenshot();
      BODY.removeEventListener('click', onClick);
      done();
    }

    BODY.addEventListener('click', onClick);

    append(BODY, container1);
    await matchScreenshot();

    BODY.click();
  });

  it('end-001', async done => {
    let containerStyle = {
      backgroundColor: 'fuchsia',
      color: 'black',
      font: '20px',
      margin: '10px',
    };
    let innerDivStyle = {
      margin: '10px 0',
    };
    let nodeToDeleteStyle = {
      borderLeft: '5px solid yellow',
      borderRight: '5px solid yellow',
    };
    let nodeToDelete = create(
      'span',
      nodeToDeleteStyle,
      createText('Span to remove')
    );
    let container1 = create('div', containerStyle, [
      create('div', innerDivStyle, createText('First block')),
      createText('\nAnonymous second block\n'),
      create('div', innerDivStyle, createText('Third block')),
      nodeToDelete,
    ]);

    async function onClick() {
      container1.removeChild(nodeToDelete);
      await matchScreenshot();
      BODY.removeEventListener('click', onClick);
      done();
    }

    BODY.addEventListener('click', onClick);

    append(BODY, container1);
    await matchScreenshot();

    BODY.click();
  });

  it('middle-001', async done => {
    let containerStyle = {
      backgroundColor: 'fuchsia',
      color: 'black',
      font: '20px',
      margin: '10px',
    };
    let innerDivStyle = {
      margin: '10px 0',
    };
    let nodeToDeleteStyle = {
      borderLeft: '5px solid yellow',
      borderRight: '5px solid yellow',
    };
    let nodeToDelete = create(
      'span',
      nodeToDeleteStyle,
      createText('Span to remove')
    );
    let container1 = create('div', containerStyle, [
      create('div', innerDivStyle, createText('First block')),
      createText('\nAnonymous second block\n'),
      nodeToDelete,
      create('div', innerDivStyle, createText('Third block')),
    ]);

    async function onClick() {
      container1.removeChild(nodeToDelete);
      await matchScreenshot();
      BODY.removeEventListener('click', onClick);
      done();
    }

    BODY.addEventListener('click', onClick);

    append(BODY, container1);
    await matchScreenshot();

    BODY.click();
  });

  it('middle-002', async done => {
    let containerStyle = {
      backgroundColor: 'fuchsia',
      color: 'black',
      font: '20px',
      margin: '10px',
    };
    let innerDivStyle = {
      margin: '10px 0',
    };
    let nodeToDeleteStyle = {
      borderLeft: '5px solid yellow',
      borderRight: '5px solid yellow',
    };
    let nodeToDelete = create(
      'span',
      nodeToDeleteStyle,
      createText('Span to remove')
    );
    let container1 = create('div', containerStyle, [
      create('div', innerDivStyle, createText('First block')),
      nodeToDelete,
      create('div', innerDivStyle, createText('Second block')),
      create('div', innerDivStyle, createText('Third block')),
    ]);

    async function onClick() {
      container1.removeChild(nodeToDelete);
      await matchScreenshot();
      BODY.removeEventListener('click', onClick);
      done();
    }

    BODY.addEventListener('click', onClick);

    append(BODY, container1);
    await matchScreenshot();

    BODY.click();
  });

  it('middle-003', async done => {
    let containerStyle = {
      backgroundColor: 'fuchsia',
      color: 'black',
      font: '20px',
      margin: '10px',
    };
    let innerDivStyle = {
      margin: '10px 0em',
    };
    let nodeToDeleteStyle = {
      borderLeft: '5px solid yellow',
      borderRight: '5px solid yellow',
    };
    let nodeToDelete = create(
      'span',
      nodeToDeleteStyle,
      createText('Span to remove')
    );
    let container1 = create('div', containerStyle, [
      create('div', innerDivStyle, createText('First block')),
      create('div', innerDivStyle, createText('Second block')),
      nodeToDelete,
      create('div', innerDivStyle, createText('Third block')),
    ]);

    async function onClick() {
      container1.removeChild(nodeToDelete);
      await matchScreenshot();
      BODY.removeEventListener('click', onClick);
      done();
    }

    BODY.addEventListener('click', onClick);

    append(BODY, container1);
    await matchScreenshot();

    BODY.click();
  });
});
