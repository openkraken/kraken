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

    title('Test passes if the 2 colorized rectangles are identical');

    let insertBlock = create('div', insertedStyle, createText('Inserted new block'));

    let insertPoint = create('span', {}, createText('Several '));
    let container = create('div', containerStyle, [
      insertPoint,
      create('span', {}, createText(' inline elements')),
      createText(' are '),
      create('span', {}, createText('in this')),
      createText(' sentence.')
    ]);

    let container2 = create('div', containerStyle, [
      create('div', insertedStyle, createText('Inserted new block')),
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

    title('Test passes if the 2 colorized rectangles are identical');

    let insertBlock = create('div', insertedStyle, createText('Inserted new block'));

    let container = create('div', containerStyle, [
      create('span', {}, createText(' inline elements')),
      createText(' are '),
      create('span', {}, createText('in this')),
      createText(' sentence.')
    ]);

    let container2 = create('div', containerStyle, [
      createText('Several inline elements are in this sentence.'),
      create('div', insertedStyle, createText('Inserted new block'))
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

    title('Test passes if the 2 colorized rectangles are identical');

    let insertBlock = create('div', insertedStyle, createText('Inserted new block'));

    let insertPoint = create('span', {}, createText('are'));
    let container = create('div', containerStyle, [
      create('span', {}, createText('Several inline')),
      create('span', {}, createText(' element ')),
      insertPoint,
      create('span', {}, createText('in this')),
      createText(' sentence.')
    ]);

    let container2 = create('div', containerStyle, [
      createText('Several inline elements '),
      create('div', insertedStyle, createText('Inserted new block')),
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