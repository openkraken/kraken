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

    let inserted = createElementWithStyle(
      'div',
      {
        borderLeft: '3px solid yellow',
        borderRight: '3px solid yellow',
      },
      createText('Inserted new Block')
    );

    BODY.addEventListener('click', async function onClick() {
      element.insertBefore(inserted, firstBlock);
      await snapshot();
      BODY.removeEventListener('click', onClick);
      element.removeChild(inserted);
      await snapshot();
      done();
    });

    let firstBlock = createElementWithStyle('div', childDivStyle, createText('1stBlock'));

    let element = createElementWithStyle('div', containerStyle, [
      firstBlock,
      createElementWithStyle('div', childDivStyle, createText('2stBlock')),
      createElementWithStyle('div', childDivStyle, createText('3stBlock')),
      createElementWithStyle('div', childDivStyle, createText('4stBlock')),
    ]);

    append(BODY, element);
    await snapshot();

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

    let inserted = createElementWithStyle(
      'div',
      {
        borderLeft: '3px solid yellow',
        borderRight: '3px solid yellow',
      },
      createText('Inserted new Block')
    );

    BODY.addEventListener('click', async function onClick() {
      element.insertBefore(inserted, insertPoint);
      await snapshot();
      BODY.removeEventListener('click', onClick);
      element.removeChild(inserted);
      await snapshot();
      done();
    });

    let insertPoint = createElementWithStyle('div', childDivStyle, createText('2stBlock'));

    let element = createElementWithStyle('div', containerStyle, [
      createElementWithStyle('div', childDivStyle, createText('1stBlock')),
      insertPoint,
      createElementWithStyle('div', childDivStyle, createText('3stBlock')),
      createElementWithStyle('div', childDivStyle, createText('4stBlock')),
    ]);

    append(BODY, element);
    await snapshot();

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

    let inserted = createElementWithStyle(
      'div',
      {
        borderLeft: '3px solid yellow',
        borderRight: '3px solid yellow',
      },
      createText('Inserted new Block')
    );

    BODY.addEventListener('click', async function onClick() {
      element.insertBefore(inserted, insertPoint);
      await snapshot();
      BODY.removeEventListener('click', onClick);
      element.removeChild(inserted);
      await snapshot();
      done();
    });

    let insertPoint = createElementWithStyle('span', childDivStyle, createText('1stinline'));

    let element = createElementWithStyle('div', containerStyle, [
      createElementWithStyle('div', childDivStyle, createText('1stBlock')),
      createElementWithStyle('div', childDivStyle, createText('2stBlock')),
      insertPoint,
      createElementWithStyle('div', childDivStyle, createText('3stBlock')),
      createElementWithStyle('div', childDivStyle, createText('4stBlock')),
    ]);

    append(BODY, element);
    await snapshot();

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

    let inserted = createElementWithStyle(
      'div',
      {
        borderLeft: '3px solid yellow',
        borderRight: '3px solid yellow',
      },
      createText('Inserted new Block')
    );

    BODY.addEventListener('click', async function onClick() {
      element.insertBefore(inserted, insertPoint);
      await snapshot();
      BODY.removeEventListener('click', onClick);
      element.removeChild(inserted);
      await snapshot();
      done();
    });

    let insertPoint = createElementWithStyle('div', childDivStyle, createText('3stBlock'));

    let element = createElementWithStyle('div', containerStyle, [
      createElementWithStyle('div', childDivStyle, createText('1stBlock')),
      createElementWithStyle('div', childDivStyle, createText('2stBlock')),
      createElementWithStyle('span', {}, createText('1stInline')),
      insertPoint,
      createElementWithStyle('div', childDivStyle, createText('4stBlock')),
    ]);

    append(BODY, element);
    await snapshot();

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

    let inserted = createElementWithStyle(
      'div',
      {
        borderLeft: '3px solid yellow',
        borderRight: '3px solid yellow',
      },
      createText('Inserted new Block')
    );

    BODY.addEventListener('click', async function onClick() {
      element.insertBefore(inserted, insertPoint);
      await snapshot();
      BODY.removeEventListener('click', onClick);
      element.removeChild(inserted);
      await snapshot();
      done();
    });

    let insertPoint = createElementWithStyle('div', childDivStyle, createText('3stBlock'));

    let element = createElementWithStyle('div', containerStyle, [
      createElementWithStyle('div', childDivStyle, createText('1stBlock')),
      createElementWithStyle('div', childDivStyle, createText('2stBlock')),
      createElementWithStyle('div', {}, createText('1stBlock')),
      insertPoint,
      createElementWithStyle('div', childDivStyle, createText('4stBlock')),
    ]);

    append(BODY, element);
    await snapshot();

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

    let inserted = createElementWithStyle(
      'div',
      {
        borderLeft: '3px solid yellow',
        borderRight: '3px solid yellow',
      },
      createText('Inserted new Block')
    );

    BODY.addEventListener('click', async function onClick() {
      element.insertBefore(inserted, insertPoint);
      await snapshot();
      BODY.removeEventListener('click', onClick);
      element.removeChild(inserted);
      await snapshot();
      done();
    });

    let insertPoint = createElementWithStyle('div', childDivStyle, createText('3stBlock'));

    let element = createElementWithStyle('div', containerStyle, [
      createElementWithStyle('div', childDivStyle, createText('1stBlock')),
      createElementWithStyle('div', childDivStyle, createText('2stBlock')),
      createElementWithStyle('div', {}, createText('1stBlock')),
      createElementWithStyle('div', childDivStyle, createText('4stBlock')),
      insertPoint,
    ]);

    append(BODY, element);
    await snapshot();

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

    let inserted = createElementWithStyle(
      'div',
      {
        borderLeft: '3px solid yellow',
        borderRight: '3px solid yellow',
      },
      createText('Inserted new Block')
    );

    BODY.addEventListener('click', async function onClick() {
      element.insertBefore(inserted, insertPoint);
      await snapshot();
      BODY.removeEventListener('click', onClick);
      element.removeChild(inserted);
      await snapshot();
      done();
    });

    let insertPoint = createElementWithStyle('div', childDivStyle, createText('3stBlock'));

    let element = createElementWithStyle('div', containerStyle, [
      createElementWithStyle('div', childDivStyle, createText('1stBlock')),
      createElementWithStyle('div', childDivStyle, createText('2stBlock')),
      insertPoint,
      createElementWithStyle('div', childDivStyle, createText('3stBlock')),
      createElementWithStyle('div', childDivStyle, createText('4stBlock')),
    ]);

    append(BODY, element);
    await snapshot();

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

    let inserted = createElementWithStyle(
      'div',
      {
        borderLeft: '3px solid yellow',
        borderRight: '3px solid yellow',
      },
      createText('Inserted new Block')
    );

    BODY.addEventListener('click', async function onClick() {
      element.insertBefore(inserted, insertPoint);
      await snapshot();
      BODY.removeEventListener('click', onClick);
      element.removeChild(inserted);
      await snapshot();
      done();
    });

    let insertPoint = createElementWithStyle('div', childDivStyle, createText('3stBlock'));

    let element = createElementWithStyle('div', containerStyle, [
      createElementWithStyle('div', childDivStyle, createText('1stBlock')),
      createElementWithStyle('div', childDivStyle, createText('2stBlock')),
      createElementWithStyle('span', {}, createText('1sit Inline')),
      createElementWithStyle('div', childDivStyle, createText('3stBlock')),
      insertPoint,
      createElementWithStyle('span', {}, createText('second inline')),
      createElementWithStyle('div', childDivStyle, createText('4stBlock')),
    ]);

    append(BODY, element);
    await snapshot();

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

    let inserted = createElementWithStyle(
      'div',
      {
        borderLeft: '3px solid yellow',
        borderRight: '3px solid yellow',
      },
      createText('Inserted new Block')
    );

    BODY.addEventListener('click', async function onClick() {
      element.insertBefore(inserted, insertPoint);
      await snapshot();
      BODY.removeEventListener('click', onClick);
      element.removeChild(inserted);
      await snapshot();
      done();
    });

    let insertPoint = createElementWithStyle('div', childDivStyle, createText('3stBlock'));

    let element = createElementWithStyle('div', containerStyle, [
      createElementWithStyle('div', childDivStyle, createText('1stBlock')),
      createElementWithStyle('div', childDivStyle, createText('2stBlock')),
      createElementWithStyle('span', {}, createText('1sit Inline')),
      createElementWithStyle('div', childDivStyle, createText('3stBlock')),
      insertPoint,
      createElementWithStyle('div', childDivStyle, createText('second inline')),
      createElementWithStyle('div', childDivStyle, createText('4stBlock')),
    ]);

    append(BODY, element);
    await snapshot();

    BODY.click();
  });
});
