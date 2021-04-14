describe('insert-inline-in-blocks', () => {
  it('beginning-001', async done => {
    let containerStyle = {
      backgroundColor: 'fuchsia',
      color: 'black',
      font: '20px',
      margin: '10px'
    };
    let innerDivStyle = {
      margin: '10px 0'
    };
    let insertedStyle = {
      borderLeft: '5px solid yellow',
      borderRight: '5px solid yellow'
    };

    let insertPoint = createElementWithStyle('div', innerDivStyle, createText('First block'));

    let container1 = createElementWithStyle('div', containerStyle, [
      insertPoint,
      createText('Anonymous second block'),
      createElementWithStyle('div', innerDivStyle, createText('Third block'))
    ]);

    let insertBlock = createElementWithStyle('span', insertedStyle, createText('Inserted new inline'));

    let container2 = createElementWithStyle('div', containerStyle, [
      createElementWithStyle('span', insertedStyle, createText('Inserted new inline')),
      createElementWithStyle('div', innerDivStyle, createText('First block')),
      createText('Anonymous second block'),
      createElementWithStyle('div', innerDivStyle, createText('Third block'))
    ]);

    BODY.addEventListener('click', async function onClick() {
      container1.insertBefore(insertBlock, insertPoint);
      await snapshot();
      BODY.removeEventListener('click', onClick);
      container1.removeChild(insertBlock);
      await snapshot();
      done();
    });

    append(BODY, container1);
    append(BODY, container2);

    await snapshot();

    BODY.click();
  });

  it('end-001', async done => {
    let containerStyle = {
      backgroundColor: 'fuchsia',
      color: 'black',
      font: '20px',
      margin: '10px'
    };
    let innerDivStyle = {
      margin: '10px 0'
    };
    let insertedStyle = {
      borderLeft: '5px solid yellow',
      borderRight: '5px solid yellow'
    };

    let container1 = createElementWithStyle('div', containerStyle, [
      createElementWithStyle('div', innerDivStyle, createText('First block')),
      createText('Anonymous second block'),
      createElementWithStyle('div', innerDivStyle, createText('Third block'))
    ]);

    let insertBlock = createElementWithStyle('span', insertedStyle, createText('Inserted new inline'));

    let container2 = createElementWithStyle('div', containerStyle, [
      createElementWithStyle('div', innerDivStyle, createText('First block')),
      createText('Anonymous second block'),
      createElementWithStyle('div', innerDivStyle, createText('Third block')),
      createElementWithStyle('span', insertedStyle, createText('Inserted new inline')),
    ]);

    BODY.addEventListener('click', async function onClick() {
      container1.appendChild(insertBlock);
      await snapshot();
      BODY.removeEventListener('click', onClick);
      container1.removeChild(insertBlock);
      await snapshot();
      done();
    });

    append(BODY, container1);
    append(BODY, container2);

    await snapshot();

    BODY.click();
  });

  it('middle-001', async done => {
    let containerStyle = {
      backgroundColor: 'fuchsia',
      color: 'black',
      font: '20px',
      margin: '10px'
    };
    let innerDivStyle = {
      margin: '10px 0'
    };
    let insertedStyle = {
      borderLeft: '5px solid yellow',
      borderRight: '5px solid yellow'
    };

    let insertPoint = createElementWithStyle('div', innerDivStyle, createText('Second block'));
    let container1 = createElementWithStyle('div', containerStyle, [
      createElementWithStyle('div', innerDivStyle, createText('First block')),
      insertPoint,
      createElementWithStyle('div', innerDivStyle, createText('Third block'))
    ]);

    let insertBlock = createElementWithStyle('span', insertedStyle, createText('Inserted new inline'));

    let container2 = createElementWithStyle('div', containerStyle, [
      createElementWithStyle('div', innerDivStyle, createText('First block')),
      createElementWithStyle('span', insertedStyle, createText('Inserted new inline')),
      createElementWithStyle('div', innerDivStyle, createText('Second block')),
      createElementWithStyle('div', innerDivStyle, createText('Third block')),
    ]);

    BODY.addEventListener('click', async function onClick() {
      container1.insertBefore(insertBlock, insertPoint);
      await snapshot();
      BODY.removeEventListener('click', onClick);
      container1.removeChild(insertBlock);
      await snapshot();
      done();
    });

    append(BODY, container1);
    append(BODY, container2);

    await snapshot();

    BODY.click();
  });

});
