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

    let insertBlock = createElement('div', insertedStyle, createText('Inserted new block'));

    let insertPoint = createElement('span', {}, createText('Several '));
    let container = createElement('div', containerStyle, [
      insertPoint,
      createElement('span', {}, createText(' inline elements')),
      createText(' are '),
      createElement('span', {}, createText('in this')),
      createText(' sentence.')
    ]);

    let container2 = createElement('div', containerStyle, [
      createElement('div', insertedStyle, createText('Inserted new block')),
      createText('Several inline elements are in this sentence.')
    ]);

    BODY.addEventListener('click', async function onClick() {
      insertPoint.insertBefore(insertBlock, insertPoint);
      await matchScreenshot();
      BODY.removeEventListener('click', onClick);
      container.removeChild(insertBlock);
      await matchScreenshot();
      done();
    });

    append(BODY, container);
    append(BODY, container2);
    await matchScreenshot();

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

    let insertBlock = createElement('div', insertedStyle, createText('Inserted new block'));

    let container = createElement('div', containerStyle, [
      createElement('span', {}, createText(' inline elements')),
      createText(' are '),
      createElement('span', {}, createText('in this')),
      createText(' sentence.')
    ]);

    let container2 = createElement('div', containerStyle, [
      createText('Several inline elements are in this sentence.'),
      createElement('div', insertedStyle, createText('Inserted new block'))
    ]);

    BODY.addEventListener('click', async function onClick() {
      container.appendChild(insertBlock);
      await matchScreenshot();
      BODY.removeEventListener('click', onClick);
      container.removeChild(insertBlock);
      await matchScreenshot();
      done();
    });

    append(BODY, container);
    append(BODY, container2);
    await matchScreenshot();

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

    let insertBlock = createElement('div', insertedStyle, createText('Inserted new block'));

    let insertPoint = createElement('span', {}, createText('are'));
    let container = createElement('div', containerStyle, [
      createElement('span', {}, createText('Several inline')),
      createElement('span', {}, createText(' element ')),
      insertPoint,
      createElement('span', {}, createText('in this')),
      createText(' sentence.')
    ]);

    let container2 = createElement('div', containerStyle, [
      createText('Several inline elements '),
      createElement('div', insertedStyle, createText('Inserted new block')),
      createText('are in this sentence.')
    ]);

    BODY.addEventListener('click', async function onClick() {
      container.insertBefore(insertBlock, insertPoint);
      await matchScreenshot();
      BODY.removeEventListener('click', onClick);
      container.removeChild(insertBlock);
      await matchScreenshot();
      done();
    });

    append(BODY, container);
    append(BODY, container2);
    await matchScreenshot();

    BODY.click();
  });
});
