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

    let insertPoint = createElement('div', innerDivStyle, createText('First block'));

    let container1 = createElement('div', containerStyle, [
      insertPoint,
      createText('Anonymous second block'),
      createElement('div', innerDivStyle, createText('Third block'))
    ]);

    let insertBlock = createElement('span', insertedStyle, createText('Inserted new inline'));

    let container2 = createElement('div', containerStyle, [
      createElement('span', insertedStyle, createText('Inserted new inline')),
      createElement('div', innerDivStyle, createText('First block')),
      createText('Anonymous second block'),
      createElement('div', innerDivStyle, createText('Third block'))
    ]);

    BODY.addEventListener('click', async function onClick() {
      insertPoint.insertBefore(insertBlock, insertPoint);
      await matchScreenshot();
      BODY.removeEventListener('click', onClick);
      container1.removeChild(insertBlock);
      await matchScreenshot();
      done();
    });

    append(BODY, container1);
    append(BODY, container2);

    await matchScreenshot();

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

    let container1 = createElement('div', containerStyle, [
      createElement('div', innerDivStyle, createText('First block')),
      createText('Anonymous second block'),
      createElement('div', innerDivStyle, createText('Third block'))
    ]);

    let insertBlock = createElement('span', insertedStyle, createText('Inserted new inline'));

    let container2 = createElement('div', containerStyle, [
      createElement('div', innerDivStyle, createText('First block')),
      createText('Anonymous second block'),
      createElement('div', innerDivStyle, createText('Third block')),
      createElement('span', insertedStyle, createText('Inserted new inline')),
    ]);

    BODY.addEventListener('click', async function onClick() {
      container1.appendChild(insertBlock);
      await matchScreenshot();
      BODY.removeEventListener('click', onClick);
      container1.removeChild(insertBlock);
      await matchScreenshot();
      done();
    });

    append(BODY, container1);
    append(BODY, container2);

    await matchScreenshot();

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

    let insertPoint = createElement('div', innerDivStyle, createText('Second block'));
    let container1 = createElement('div', containerStyle, [
      createElement('div', innerDivStyle, createText('First block')),
      insertPoint,
      createElement('div', innerDivStyle, createText('Third block'))
    ]);

    let insertBlock = createElement('span', insertedStyle, createText('Inserted new inline'));

    let container2 = createElement('div', containerStyle, [
      createElement('div', innerDivStyle, createText('First block')),
      createElement('span', insertedStyle, createText('Inserted new inline')),
      createElement('div', innerDivStyle, createText('Second block')),
      createElement('div', innerDivStyle, createText('Third block')),
    ]);

    BODY.addEventListener('click', async function onClick() {
      container1.insertBefore(insertBlock, insertPoint);
      await matchScreenshot();
      BODY.removeEventListener('click', onClick);
      container1.removeChild(insertBlock);
      await matchScreenshot();
      done();
    });

    append(BODY, container1);
    append(BODY, container2);

    await matchScreenshot();

    BODY.click();
  });

});
