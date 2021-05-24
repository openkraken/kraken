describe('insert-block-in-inlines', () => {
  it('beginning-001', async (done) => {
    let containerStyle = {
      backgroundColor: 'fuchsia',
      color: 'black',
      font: '20px',
      margin: '10px'
    };
    let insertedStyle = {
      borderLeft: '5px solid yellow',
      borderRight: '5px solid yellow',
      margin: '10px 0'
    };

    let insertBlock = createElementWithStyle('div', insertedStyle, createText('Inserted new block'));

    let insertPoint = createElementWithStyle('span', {}, createText('Several '));
    let container = createElementWithStyle('div', containerStyle, [
      insertPoint,
      createElementWithStyle('span', {}, createText(' inline elements')),
      createText(' are '),
      createElementWithStyle('span', {}, createText('in this')),
      createText(' sentence.')
    ]);

    let container2 = createElementWithStyle('div', containerStyle, [
      createElementWithStyle('div', insertedStyle, createText('Inserted new block')),
      createText('Several inline elements are in this sentence.')
    ]);

    BODY.addEventListener('click', async function onClick() {
      container.insertBefore(insertBlock, insertPoint);
      await snapshot();
      BODY.removeEventListener('click', onClick);
      container.removeChild(insertBlock);
      await snapshot();
      done();
    });

    append(BODY, container);
    append(BODY, container2);
    await snapshot();

    BODY.click();
  });

  it('end-001', async (done) => {
    let containerStyle = {
      backgroundColor: 'fuchsia',
      color: 'black',
      font: '20px',
      margin: '10px'
    };
    let insertedStyle = {
      borderLeft: '5px solid yellow',
      borderRight: '5px solid yellow',
      margin: '10px 0'
    };

    let insertBlock = createElementWithStyle('div', insertedStyle, createText('Inserted new block'));

    let container = createElementWithStyle('div', containerStyle, [
      createElementWithStyle('span', {}, createText(' inline elements')),
      createText(' are '),
      createElementWithStyle('span', {}, createText('in this')),
      createText(' sentence.')
    ]);

    let container2 = createElementWithStyle('div', containerStyle, [
      createText('Several inline elements are in this sentence.'),
      createElementWithStyle('div', insertedStyle, createText('Inserted new block'))
    ]);

    BODY.addEventListener('click', async function onClick() {
      container.appendChild(insertBlock);
      await snapshot();
      BODY.removeEventListener('click', onClick);
      container.removeChild(insertBlock);
      await snapshot();
      done();
    });

    append(BODY, container);
    append(BODY, container2);
    await snapshot();

    BODY.click();
  });

  it('middle-001', async (done) => {
    let containerStyle = {
      backgroundColor: 'fuchsia',
      color: 'black',
      font: '20px',
      margin: '10px'
    };
    let insertedStyle = {
      borderLeft: '5px solid yellow',
      borderRight: '5px solid yellow',
      margin: '10px 0'
    };

    let insertBlock = createElementWithStyle('div', insertedStyle, createText('Inserted new block'));

    let insertPoint = createElementWithStyle('span', {}, createText('are'));
    let container = createElementWithStyle('div', containerStyle, [
      createElementWithStyle('span', {}, createText('Several inline')),
      createElementWithStyle('span', {}, createText(' element ')),
      insertPoint,
      createElementWithStyle('span', {}, createText('in this')),
      createText(' sentence.')
    ]);

    let container2 = createElementWithStyle('div', containerStyle, [
      createText('Several inline elements '),
      createElementWithStyle('div', insertedStyle, createText('Inserted new block')),
      createText('are in this sentence.')
    ]);

    BODY.addEventListener('click', async function onClick() {
      container.insertBefore(insertBlock, insertPoint);
      await snapshot();
      BODY.removeEventListener('click', onClick);
      container.removeChild(insertBlock);
      await snapshot();
      done();
    });

    append(BODY, container);
    append(BODY, container2);
    await snapshot();

    BODY.click();
  });
});
