fdescribe('insert-block-in-blocks-n-inlines', () => {
  it('begin-001', async done => {
    let containerStyle = {
      backgroundColor: 'fuchsia',
      color: 'black',
      font: '20px',
      margin: '10px',
    };

    let childDivStyle = {
      margin: '10px 0',
    };

    let inserted = create(
      'div',
      {
        borderLeft: '3px solid yellow',
        borderRight: '3px solid yellow',
      },
      createText('Inserted new Block')
    );

    BODY.addEventListener('click', async function onClick() {
      element.insertBefore(inserted, firstBlock);
      await matchScreenshot();
      BODY.removeEventListener('click', onClick);
      element.removeChild(inserted);
      await matchScreenshot();
      done();
    });

    let firstBlock = create('div', childDivStyle, createText('1stBlock'));

    let element = create('div', containerStyle, [
      firstBlock,
      create('div', childDivStyle, createText('2stBlock')),
      create('div', childDivStyle, createText('3stBlock')),
      create('div', childDivStyle, createText('4stBlock')),
    ]);

    append(BODY, element);
    await matchScreenshot();

    BODY.click();
  });

  it('begin-002', async done => {
    let containerStyle = {
      backgroundColor: 'fuchsia',
      color: 'black',
      font: '20px',
      margin: '10px',
    };

    let childDivStyle = {
      margin: '10px 0',
    };

    let inserted = create(
      'div',
      {
        borderLeft: '3px solid yellow',
        borderRight: '3px solid yellow',
      },
      createText('Inserted new Block')
    );

    BODY.addEventListener('click', async function onClick() {
      element.insertBefore(inserted, insertPoint);
      await matchScreenshot();
      BODY.removeEventListener('click', onClick);
      element.removeChild(inserted);
      await matchScreenshot();
      done();
    });

    let insertPoint = create('div', childDivStyle, createText('2stBlock'));

    let element = create('div', containerStyle, [
      create('div', childDivStyle, createText('1stBlock')),
      insertPoint,
      create('div', childDivStyle, createText('3stBlock')),
      create('div', childDivStyle, createText('4stBlock')),
    ]);

    append(BODY, element);
    await matchScreenshot();

    BODY.click();
  });

  it('begin-003', async done => {
    let containerStyle = {
      backgroundColor: 'fuchsia',
      color: 'black',
      font: '20px',
      margin: '10px',
    };

    let childDivStyle = {
      margin: '10px 0',
    };

    let inserted = create(
      'div',
      {
        borderLeft: '3px solid yellow',
        borderRight: '3px solid yellow',
      },
      createText('Inserted new Block')
    );

    BODY.addEventListener('click', async function onClick() {
      element.insertBefore(inserted, insertPoint);
      await matchScreenshot();
      BODY.removeEventListener('click', onClick);
      element.removeChild(inserted);
      await matchScreenshot();
      done();
    });

    let insertPoint = create('span', childDivStyle, createText('1stinline'));

    let element = create('div', containerStyle, [
      create('div', childDivStyle, createText('1stBlock')),
      create('div', childDivStyle, createText('2stBlock')),
      insertPoint,
      create('div', childDivStyle, createText('3stBlock')),
      create('div', childDivStyle, createText('4stBlock')),
    ]);

    append(BODY, element);
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

    let childDivStyle = {
      margin: '10px 0',
    };

    let inserted = create(
      'div',
      {
        borderLeft: '3px solid yellow',
        borderRight: '3px solid yellow',
      },
      createText('Inserted new Block')
    );

    BODY.addEventListener('click', async function onClick() {
      element.insertBefore(inserted, insertPoint);
      await matchScreenshot();
      BODY.removeEventListener('click', onClick);
      element.removeChild(inserted);
      await matchScreenshot();
      done();
    });

    let insertPoint = create('div', childDivStyle, createText('3stBlock'));

    let element = create('div', containerStyle, [
      create('div', childDivStyle, createText('1stBlock')),
      create('div', childDivStyle, createText('2stBlock')),
      create('span', {}, createText('1stInline')),
      insertPoint,
      create('div', childDivStyle, createText('4stBlock')),
    ]);

    append(BODY, element);
    await matchScreenshot();

    BODY.click();
  });

  it('end-002', async done => {
    let containerStyle = {
      backgroundColor: 'fuchsia',
      color: 'black',
      font: '20px',
      margin: '10px',
    };

    let childDivStyle = {
      margin: '10px 0',
    };

    let inserted = create(
      'div',
      {
        borderLeft: '3px solid yellow',
        borderRight: '3px solid yellow',
      },
      createText('Inserted new Block')
    );

    BODY.addEventListener('click', async function onClick() {
      element.insertBefore(inserted, insertPoint);
      await matchScreenshot();
      BODY.removeEventListener('click', onClick);
      element.removeChild(inserted);
      await matchScreenshot();
      done();
    });

    let insertPoint = create('div', childDivStyle, createText('3stBlock'));

    let element = create('div', containerStyle, [
      create('div', childDivStyle, createText('1stBlock')),
      create('div', childDivStyle, createText('2stBlock')),
      create('div', {}, createText('1stBlock')),
      insertPoint,
      create('div', childDivStyle, createText('4stBlock')),
    ]);

    append(BODY, element);
    await matchScreenshot();

    BODY.click();
  });

  it('end-003', async done => {
    let containerStyle = {
      backgroundColor: 'fuchsia',
      color: 'black',
      font: '20px',
      margin: '10px',
    };

    let childDivStyle = {
      margin: '10px 0',
    };

    let inserted = create(
      'div',
      {
        borderLeft: '3px solid yellow',
        borderRight: '3px solid yellow',
      },
      createText('Inserted new Block')
    );

    BODY.addEventListener('click', async function onClick() {
      element.insertBefore(inserted, insertPoint);
      await matchScreenshot();
      BODY.removeEventListener('click', onClick);
      element.removeChild(inserted);
      await matchScreenshot();
      done();
    });

    let insertPoint = create('div', childDivStyle, createText('3stBlock'));

    let element = create('div', containerStyle, [
      create('div', childDivStyle, createText('1stBlock')),
      create('div', childDivStyle, createText('2stBlock')),
      create('div', {}, createText('1stBlock')),
      create('div', childDivStyle, createText('4stBlock')),
      insertPoint,
    ]);

    append(BODY, element);
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

    let childDivStyle = {
      margin: '10px 0',
    };

    let inserted = create(
      'div',
      {
        borderLeft: '3px solid yellow',
        borderRight: '3px solid yellow',
      },
      createText('Inserted new Block')
    );

    BODY.addEventListener('click', async function onClick() {
      element.insertBefore(inserted, insertPoint);
      await matchScreenshot();
      BODY.removeEventListener('click', onClick);
      element.removeChild(inserted);
      await matchScreenshot();
      done();
    });

    let insertPoint = create('div', childDivStyle, createText('3stBlock'));

    let element = create('div', containerStyle, [
      create('div', childDivStyle, createText('1stBlock')),
      create('div', childDivStyle, createText('2stBlock')),
      insertPoint,
      create('div', childDivStyle, createText('3stBlock')),
      create('div', childDivStyle, createText('4stBlock')),
    ]);

    append(BODY, element);
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

    let childDivStyle = {
      margin: '10px 0',
    };

    let inserted = create(
      'div',
      {
        borderLeft: '3px solid yellow',
        borderRight: '3px solid yellow',
      },
      createText('Inserted new Block')
    );

    BODY.addEventListener('click', async function onClick() {
      element.insertBefore(inserted, insertPoint);
      await matchScreenshot();
      BODY.removeEventListener('click', onClick);
      element.removeChild(inserted);
      await matchScreenshot();
      done();
    });

    let insertPoint = create('div', childDivStyle, createText('3stBlock'));

    let element = create('div', containerStyle, [
      create('div', childDivStyle, createText('1stBlock')),
      create('div', childDivStyle, createText('2stBlock')),
      create('span', {}, createText('1sit Inline')),
      create('div', childDivStyle, createText('3stBlock')),
      insertPoint,
      create('span', {}, createText('second inline')),
      create('div', childDivStyle, createText('4stBlock')),
    ]);

    append(BODY, element);
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

    let childDivStyle = {
      margin: '10px 0',
    };

    let inserted = create(
      'div',
      {
        borderLeft: '3px solid yellow',
        borderRight: '3px solid yellow',
      },
      createText('Inserted new Block')
    );

    BODY.addEventListener('click', async function onClick() {
      element.insertBefore(inserted, insertPoint);
      await matchScreenshot();
      BODY.removeEventListener('click', onClick);
      element.removeChild(inserted);
      await matchScreenshot();
      done();
    });

    let insertPoint = create('div', childDivStyle, createText('3stBlock'));

    let element = create('div', containerStyle, [
      create('div', childDivStyle, createText('1stBlock')),
      create('div', childDivStyle, createText('2stBlock')),
      create('span', {}, createText('1sit Inline')),
      create('div', childDivStyle, createText('3stBlock')),
      insertPoint,
      create('div', childDivStyle, createText('second inline')),
      create('div', childDivStyle, createText('4stBlock')),
    ]);

    append(BODY, element);
    await matchScreenshot();

    BODY.click();
  });
});
