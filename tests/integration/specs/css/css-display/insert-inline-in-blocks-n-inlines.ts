describe('insert-inline-in-blocks-n-inlines', () => {
  it('begin-001', async () => {
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

    let insertPoint = createElement('span', {}, createText('1stInline'));
    let container = createElement('div', containerStyle, [
      insertPoint,
      createElement('div', innerDivStyle, createText('1stBlock')),
      createElement('span', {}, createText('FourthInline')),
      createElement('span', {}, createText('Fifth55Inline')),
      createElement('div', innerDivStyle, createText('SecondBlock')),
      createElement('span', {}, createText('Seven777Inline')),
      createElement('span', {}, createText('Eight8888Inline')),
    ]);

    let container2 = createElement('div', containerStyle, [
      createElement('span', insertedStyle, createText('Inserted new inline')),
      createElement('span', {}, createText('1stInline')),
      createElement('div', innerDivStyle, createText('1stBlock')),
      createElement('span', {}, createText('FourthInline')),
      createElement('span', {}, createText('Fifth55Inline')),
      createElement('div', innerDivStyle, createText('SecondBlock')),
      createElement('span', {}, createText('Seven777Inline')),
      createElement('span', {}, createText('Eight8888Inline')),
    ]);

    append(BODY, container);
    append(BODY, container2);

    await matchScreenshot();

    container.insertBefore(createElement('span', insertedStyle, createText('Inserted new inline')), insertPoint);

    await matchScreenshot();
  });

  it('begin-002', async () => {
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

    let insertPoint = createElement('span', {}, createText('ScndInline'));
    let container = createElement('div', containerStyle, [
      createElement('span', {}, createText('1stInline')),
      insertPoint,
      createElement('div', innerDivStyle, createText('1stBlock')),
      createElement('span', {}, createText('FourthInline')),
      createElement('span', {}, createText('Fifth55Inline')),
      createElement('div', innerDivStyle, createText('SecondBlock')),
      createElement('span', {}, createText('Seven777Inline')),
      createElement('span', {}, createText('Eight8888Inline')),
    ]);

    let container2 = createElement('div', containerStyle, [
      createElement('span', {}, createText('1stInline')),
      createElement('span', insertedStyle, createText('Inserted new inline')),
      createElement('span', {}, createText('ScndInline')),
      createElement('div', innerDivStyle, createText('1stBlock')),
      createText('FourthInline'),
      createText('Fifth55Inline'),
      createElement('div', innerDivStyle, createText('SecondBlock')),
      createText('Seven777Inline'),
      createText('Eight8888Inline')
    ]);

    append(BODY, container);
    append(BODY, container2);

    await matchScreenshot();

    container.insertBefore(createElement('span', insertedStyle, createText('Inserted new inline')), insertPoint);

    await matchScreenshot();
  });

  it('begin-003', async () => {
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

    let insertPoint = createElement('div', innerDivStyle, createText('1stBlock'));
    let container = createElement('div', containerStyle, [
      createElement('span', {}, createText('1stInline')),
      createElement('span', {}, createText('ScndInline')),
      insertPoint,
      createElement('span', {}, createText('FourthInline')),
      createElement('span', {}, createText('Fifth55Inline')),
      createElement('div', innerDivStyle, createText('SecondBlock')),
      createElement('span', {}, createText('Seven777Inline')),
      createElement('span', {}, createText('Eight8888Inline')),
    ]);

    let container2 = createElement('div', containerStyle, [
      createText('1stInline '),
      createText('ScndInline'),
      createElement('span', insertedStyle, createText('Inserted new inline')),
      createElement('div', innerDivStyle, createText('1stBlock')),
      createText('FourthInline'),
      createText('Fifth55Inline'),
      createElement('div', innerDivStyle, createText('SecondBlock')),
      createText('Seven777Inline'),
      createText('Eight8888Inline')
    ]);

    append(BODY, container);
    append(BODY, container2);

    await matchScreenshot();

    container.insertBefore(createElement('span', insertedStyle, createText('Inserted new inline')), insertPoint);

    await matchScreenshot();
  });

  it('end-001', async () => {
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

    let insertPoint = createElement('span', {}, createText('Seven777Inline'));
    let container = createElement('div', containerStyle, [
      createElement('span', {}, createText('1stInline')),
      createElement('span', {}, createText('ScndInline')),
      createElement('div', innerDivStyle, createText('1stBlock')),
      createElement('span', {}, createText('FourthInline')),
      createElement('span', {}, createText('Fifth55Inline')),
      createElement('div', innerDivStyle, createText('SecondBlock')),
      insertPoint,
      createElement('span', {}, createText('Eight8888Inline')),
    ]);

    let container2 = createElement('div', containerStyle, [
      createText('1stInline '),
      createText('ScndInline'),
      createElement('div', innerDivStyle, createText('1stBlock')),
      createText('FourthInline'),
      createText('Fifth55Inline'),
      createElement('div', innerDivStyle, createText('SecondBlock')),
      createElement('span', insertedStyle, createText('Inserted new inline')),
      createText('Seven777Inline'),
      createText('Eight8888Inline')
    ]);

    append(BODY, container);
    append(BODY, container2);

    await matchScreenshot();

    container.insertBefore(createElement('span', insertedStyle, createText('Inserted new inline')), insertPoint);

    await matchScreenshot();
  });

  it('end-002', async () => {
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

    let insertPoint = createElement('span', {}, createText('Eight8888Inline'));
    let container = createElement('div', containerStyle, [
      createElement('span', {}, createText('1stInline')),
      createElement('span', {}, createText('ScndInline')),
      createElement('div', innerDivStyle, createText('1stBlock')),
      createElement('span', {}, createText('FourthInline')),
      createElement('span', {}, createText('Fifth55Inline')),
      createElement('div', innerDivStyle, createText('SecondBlock')),
      createElement('span', {}, createText('Seven777Inline')),
      insertPoint,
    ]);

    let container2 = createElement('div', containerStyle, [
      createText('1stInline '),
      createText('ScndInline'),
      createElement('div', innerDivStyle, createText('1stBlock')),
      createText('FourthInline'),
      createText('Fifth55Inline'),
      createElement('div', innerDivStyle, createText('SecondBlock')),
      createText('Seven777Inline'),
      createElement('span', insertedStyle, createText('Inserted new inline')),
      createText('Eight8888Inline')
    ]);

    append(BODY, container);
    append(BODY, container2);

    await matchScreenshot();

    container.insertBefore(createElement('span', insertedStyle, createText('Inserted new inline')), insertPoint);

    await matchScreenshot();
  });

  it('end-003', async () => {
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

    let container = createElement('div', containerStyle, [
      createElement('span', {}, createText('1stInline')),
      createElement('span', {}, createText('ScndInline')),
      createElement('div', innerDivStyle, createText('1stBlock')),
      createElement('span', {}, createText('FourthInline')),
      createElement('span', {}, createText('Fifth55Inline')),
      createElement('div', innerDivStyle, createText('SecondBlock')),
      createElement('span', {}, createText('Seven777Inline')),
      createElement('span', {}, createText('Eight8888Inline')),
    ]);

    let container2 = createElement('div', containerStyle, [
      createText('1stInline '),
      createText('ScndInline'),
      createElement('div', innerDivStyle, createText('1stBlock')),
      createText('FourthInline'),
      createText('Fifth55Inline'),
      createElement('div', innerDivStyle, createText('SecondBlock')),
      createText('Seven777Inline'),
      createText('Eight8888Inline'),
      createElement('span', insertedStyle, createText('Inserted new inline'))
    ]);

    append(BODY, container);
    append(BODY, container2);

    await matchScreenshot();

    container.appendChild(createElement('span', insertedStyle, createText('Inserted new inline')));

    await matchScreenshot();
  });

  it('middle-001', async () => {
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

    let insertPoint = createElement('span', {}, createText('FourthInline'));
    let insertBlock = createElement('span', insertedStyle, createText('Inserted new inline'));

    let container = createElement('div', containerStyle, [
      createElement('span', {}, createText('1stInline')),
      createElement('span', {}, createText('ScndInline')),
      createElement('div', innerDivStyle, createText('1stBlock')),
      insertPoint,
      createElement('span', {}, createText('Fifth55Inline')),
      createElement('div', innerDivStyle, createText('SecondBlock')),
      createElement('span', {}, createText('Seven777Inline')),
    ]);

    let container2 = createElement('div', containerStyle, [
      createText('1stInline '),
      createText('ScndInline'),
      createElement('div', innerDivStyle, createText('1stBlock')),
      createElement('span', insertedStyle, createText('Inserted new inline')),
      createText('FourthInline'),
      createText('Fifth55Inline'),
      createElement('div', innerDivStyle, createText('SecondBlock')),
      createText('Seven777Inline'),
      createText('Eight8888Inline'),
    ]);

    append(BODY, container);
    append(BODY, container2);

    await matchScreenshot();

    container.insertBefore(insertBlock, insertPoint);

    await matchScreenshot();
  });

  it('middle-002', async () => {
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

    let insertPoint = createElement('span', {}, createText('Fifth55Inline'));
    let insertBlock = createElement('span', insertedStyle, createText('Inserted new inline'));

    let container = createElement('div', containerStyle, [
      createElement('span', {}, createText('1stInline')),
      createElement('span', {}, createText('ScndInline')),
      createElement('div', innerDivStyle, createText('1stBlock')),
      createElement('span', {}, createText('FourthInline')),
      insertPoint,
      createElement('div', innerDivStyle, createText('SecondBlock')),
      createElement('span', {}, createText('Seven777Inline')),
    ]);

    let container2 = createElement('div', containerStyle, [
      createText('1stInline '),
      createText('ScndInline'),
      createElement('div', innerDivStyle, createText('1stBlock')),
      createText('FourthInline'),
      createElement('span', insertedStyle, createText('Inserted new inline')),
      createText('Fifth55Inline'),
      createElement('div', innerDivStyle, createText('SecondBlock')),
      createText('Seven777Inline'),
      createText('Eight8888Inline'),
    ]);

    append(BODY, container);
    append(BODY, container2);

    await matchScreenshot();

    container.insertBefore(insertBlock, insertPoint);

    await matchScreenshot();
  });

  it('middle-003', async () => {
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

    let insertPoint = createElement('div', innerDivStyle, createText('SecondBlock'));
    let insertBlock = createElement('span', insertedStyle, createText('Inserted new inline'));

    let container = createElement('div', containerStyle, [
      createElement('span', {}, createText('1stInline')),
      createElement('span', {}, createText('ScndInline')),
      createElement('div', innerDivStyle, createText('1stBlock')),
      createElement('span', {}, createText('FourthInline')),
      createElement('span', {}, createText('Fifth55Inline')),
      insertPoint,
      createElement('span', {}, createText('Seven777Inline')),
    ]);

    let container2 = createElement('div', containerStyle, [
      createText('1stInline '),
      createText('ScndInline'),
      createElement('div', innerDivStyle, createText('1stBlock')),
      createText('FourthInline'),
      createText('Fifth55Inline'),
      createElement('span', insertedStyle, createText('Inserted new inline')),
      createElement('div', innerDivStyle, createText('SecondBlock')),
      createText('Seven777Inline'),
      createText('Eight8888Inline'),
    ]);

    append(BODY, container);
    append(BODY, container2);

    await matchScreenshot();

    container.insertBefore(insertBlock, insertPoint);

    await matchScreenshot();
  });
});
