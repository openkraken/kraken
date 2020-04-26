describe('insert-block-in-blocks-n-inlines', () => {
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

    let inserted = createElement(
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

    let firstBlock = createElement('div', childDivStyle, createText('1stBlock'));

    let element = createElement('div', containerStyle, [
      firstBlock,
      createElement('div', childDivStyle, createText('2stBlock')),
      createElement('div', childDivStyle, createText('3stBlock')),
      createElement('div', childDivStyle, createText('4stBlock')),
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

    let inserted = createElement(
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

    let insertPoint = createElement('div', childDivStyle, createText('2stBlock'));

    let element = createElement('div', containerStyle, [
      createElement('div', childDivStyle, createText('1stBlock')),
      insertPoint,
      createElement('div', childDivStyle, createText('3stBlock')),
      createElement('div', childDivStyle, createText('4stBlock')),
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

    let inserted = createElement(
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

    let insertPoint = createElement('span', childDivStyle, createText('1stinline'));

    let element = createElement('div', containerStyle, [
      createElement('div', childDivStyle, createText('1stBlock')),
      createElement('div', childDivStyle, createText('2stBlock')),
      insertPoint,
      createElement('div', childDivStyle, createText('3stBlock')),
      createElement('div', childDivStyle, createText('4stBlock')),
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

    let inserted = createElement(
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

    let insertPoint = createElement('div', childDivStyle, createText('3stBlock'));

    let element = createElement('div', containerStyle, [
      createElement('div', childDivStyle, createText('1stBlock')),
      createElement('div', childDivStyle, createText('2stBlock')),
      createElement('span', {}, createText('1stInline')),
      insertPoint,
      createElement('div', childDivStyle, createText('4stBlock')),
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

    let inserted = createElement(
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

    let insertPoint = createElement('div', childDivStyle, createText('3stBlock'));

    let element = createElement('div', containerStyle, [
      createElement('div', childDivStyle, createText('1stBlock')),
      createElement('div', childDivStyle, createText('2stBlock')),
      createElement('div', {}, createText('1stBlock')),
      insertPoint,
      createElement('div', childDivStyle, createText('4stBlock')),
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

    let inserted = createElement(
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

    let insertPoint = createElement('div', childDivStyle, createText('3stBlock'));

    let element = createElement('div', containerStyle, [
      createElement('div', childDivStyle, createText('1stBlock')),
      createElement('div', childDivStyle, createText('2stBlock')),
      createElement('div', {}, createText('1stBlock')),
      createElement('div', childDivStyle, createText('4stBlock')),
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

    let inserted = createElement(
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

    let insertPoint = createElement('div', childDivStyle, createText('3stBlock'));

    let element = createElement('div', containerStyle, [
      createElement('div', childDivStyle, createText('1stBlock')),
      createElement('div', childDivStyle, createText('2stBlock')),
      insertPoint,
      createElement('div', childDivStyle, createText('3stBlock')),
      createElement('div', childDivStyle, createText('4stBlock')),
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

    let inserted = createElement(
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

    let insertPoint = createElement('div', childDivStyle, createText('3stBlock'));

    let element = createElement('div', containerStyle, [
      createElement('div', childDivStyle, createText('1stBlock')),
      createElement('div', childDivStyle, createText('2stBlock')),
      createElement('span', {}, createText('1sit Inline')),
      createElement('div', childDivStyle, createText('3stBlock')),
      insertPoint,
      createElement('span', {}, createText('second inline')),
      createElement('div', childDivStyle, createText('4stBlock')),
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

    let inserted = createElement(
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

    let insertPoint = createElement('div', childDivStyle, createText('3stBlock'));

    let element = createElement('div', containerStyle, [
      createElement('div', childDivStyle, createText('1stBlock')),
      createElement('div', childDivStyle, createText('2stBlock')),
      createElement('span', {}, createText('1sit Inline')),
      createElement('div', childDivStyle, createText('3stBlock')),
      insertPoint,
      createElement('div', childDivStyle, createText('second inline')),
      createElement('div', childDivStyle, createText('4stBlock')),
    ]);

    append(BODY, element);
    await matchScreenshot();

    BODY.click();
  });
});
