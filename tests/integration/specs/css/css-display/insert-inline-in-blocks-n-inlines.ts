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

    let insertPoint = create('span', {}, createText('1stInline'));
    let container = create('div', containerStyle, [
      insertPoint,
      create('div', innerDivStyle, createText('1stBlock')),
      create('span', {}, createText('FourthInline')),
      create('span', {}, createText('Fifth55Inline')),
      create('div', innerDivStyle, createText('SecondBlock')),
      create('span', {}, createText('Seven777Inline')),
      create('span', {}, createText('Eight8888Inline')),
    ]);

    let container2 = create('div', containerStyle, [
      create('span', insertedStyle, createText('Inserted new inline')),
      create('span', {}, createText('1stInline')),
      create('div', innerDivStyle, createText('1stBlock')),
      create('span', {}, createText('FourthInline')),
      create('span', {}, createText('Fifth55Inline')),
      create('div', innerDivStyle, createText('SecondBlock')),
      create('span', {}, createText('Seven777Inline')),
      create('span', {}, createText('Eight8888Inline')),
    ]);

    append(BODY, container);
    append(BODY, container2);

    await matchScreenshot();

    container.insertBefore(create('span', insertedStyle, createText('Inserted new inline')), insertPoint);

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

    let insertPoint = create('span', {}, createText('ScndInline'));
    let container = create('div', containerStyle, [
      create('span', {}, createText('1stInline')),
      insertPoint,
      create('div', innerDivStyle, createText('1stBlock')),
      create('span', {}, createText('FourthInline')),
      create('span', {}, createText('Fifth55Inline')),
      create('div', innerDivStyle, createText('SecondBlock')),
      create('span', {}, createText('Seven777Inline')),
      create('span', {}, createText('Eight8888Inline')),
    ]);

    let container2 = create('div', containerStyle, [
      create('span', {}, createText('1stInline')),
      create('span', insertedStyle, createText('Inserted new inline')),
      create('span', {}, createText('ScndInline')),
      create('div', innerDivStyle, createText('1stBlock')),
      createText('FourthInline'),
      createText('Fifth55Inline'),
      create('div', innerDivStyle, createText('SecondBlock')),
      createText('Seven777Inline'),
      createText('Eight8888Inline')
    ]);

    append(BODY, container);
    append(BODY, container2);

    await matchScreenshot();

    container.insertBefore(create('span', insertedStyle, createText('Inserted new inline')), insertPoint);

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

    let insertPoint = create('div', innerDivStyle, createText('1stBlock'));
    let container = create('div', containerStyle, [
      create('span', {}, createText('1stInline')),
      create('span', {}, createText('ScndInline')),
      insertPoint,
      create('span', {}, createText('FourthInline')),
      create('span', {}, createText('Fifth55Inline')),
      create('div', innerDivStyle, createText('SecondBlock')),
      create('span', {}, createText('Seven777Inline')),
      create('span', {}, createText('Eight8888Inline')),
    ]);

    let container2 = create('div', containerStyle, [
      createText('1stInline '),
      createText('ScndInline'),
      create('span', insertedStyle, createText('Inserted new inline')),
      create('div', innerDivStyle, createText('1stBlock')),
      createText('FourthInline'),
      createText('Fifth55Inline'),
      create('div', innerDivStyle, createText('SecondBlock')),
      createText('Seven777Inline'),
      createText('Eight8888Inline')
    ]);

    append(BODY, container);
    append(BODY, container2);

    await matchScreenshot();

    container.insertBefore(create('span', insertedStyle, createText('Inserted new inline')), insertPoint);

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

    let insertPoint = create('span', {}, createText('Seven777Inline'));
    let container = create('div', containerStyle, [
      create('span', {}, createText('1stInline')),
      create('span', {}, createText('ScndInline')),
      create('div', innerDivStyle, createText('1stBlock')),
      create('span', {}, createText('FourthInline')),
      create('span', {}, createText('Fifth55Inline')),
      create('div', innerDivStyle, createText('SecondBlock')),
      insertPoint,
      create('span', {}, createText('Eight8888Inline')),
    ]);

    let container2 = create('div', containerStyle, [
      createText('1stInline '),
      createText('ScndInline'),
      create('div', innerDivStyle, createText('1stBlock')),
      createText('FourthInline'),
      createText('Fifth55Inline'),
      create('div', innerDivStyle, createText('SecondBlock')),
      create('span', insertedStyle, createText('Inserted new inline')),
      createText('Seven777Inline'),
      createText('Eight8888Inline')
    ]);

    append(BODY, container);
    append(BODY, container2);

    await matchScreenshot();

    container.insertBefore(create('span', insertedStyle, createText('Inserted new inline')), insertPoint);

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

    let insertPoint = create('span', {}, createText('Eight8888Inline'));
    let container = create('div', containerStyle, [
      create('span', {}, createText('1stInline')),
      create('span', {}, createText('ScndInline')),
      create('div', innerDivStyle, createText('1stBlock')),
      create('span', {}, createText('FourthInline')),
      create('span', {}, createText('Fifth55Inline')),
      create('div', innerDivStyle, createText('SecondBlock')),
      create('span', {}, createText('Seven777Inline')),
      insertPoint,
    ]);

    let container2 = create('div', containerStyle, [
      createText('1stInline '),
      createText('ScndInline'),
      create('div', innerDivStyle, createText('1stBlock')),
      createText('FourthInline'),
      createText('Fifth55Inline'),
      create('div', innerDivStyle, createText('SecondBlock')),
      createText('Seven777Inline'),
      create('span', insertedStyle, createText('Inserted new inline')),
      createText('Eight8888Inline')
    ]);

    append(BODY, container);
    append(BODY, container2);

    await matchScreenshot();

    container.insertBefore(create('span', insertedStyle, createText('Inserted new inline')), insertPoint);

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

    let container = create('div', containerStyle, [
      create('span', {}, createText('1stInline')),
      create('span', {}, createText('ScndInline')),
      create('div', innerDivStyle, createText('1stBlock')),
      create('span', {}, createText('FourthInline')),
      create('span', {}, createText('Fifth55Inline')),
      create('div', innerDivStyle, createText('SecondBlock')),
      create('span', {}, createText('Seven777Inline')),
      create('span', {}, createText('Eight8888Inline')),
    ]);

    let container2 = create('div', containerStyle, [
      createText('1stInline '),
      createText('ScndInline'),
      create('div', innerDivStyle, createText('1stBlock')),
      createText('FourthInline'),
      createText('Fifth55Inline'),
      create('div', innerDivStyle, createText('SecondBlock')),
      createText('Seven777Inline'),
      createText('Eight8888Inline'),
      create('span', insertedStyle, createText('Inserted new inline'))
    ]);

    append(BODY, container);
    append(BODY, container2);

    await matchScreenshot();

    container.appendChild(create('span', insertedStyle, createText('Inserted new inline')));

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

    let insertPoint = create('span', {}, createText('FourthInline'));
    let insertBlock = create('span', insertedStyle, createText('Inserted new inline'));

    let container = create('div', containerStyle, [
      create('span', {}, createText('1stInline')),
      create('span', {}, createText('ScndInline')),
      create('div', innerDivStyle, createText('1stBlock')),
      insertPoint,
      create('span', {}, createText('Fifth55Inline')),
      create('div', innerDivStyle, createText('SecondBlock')),
      create('span', {}, createText('Seven777Inline')),
    ]);

    let container2 = create('div', containerStyle, [
      createText('1stInline '),
      createText('ScndInline'),
      create('div', innerDivStyle, createText('1stBlock')),
      create('span', insertedStyle, createText('Inserted new inline')),
      createText('FourthInline'),
      createText('Fifth55Inline'),
      create('div', innerDivStyle, createText('SecondBlock')),
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

    let insertPoint = create('span', {}, createText('Fifth55Inline'));
    let insertBlock = create('span', insertedStyle, createText('Inserted new inline'));

    let container = create('div', containerStyle, [
      create('span', {}, createText('1stInline')),
      create('span', {}, createText('ScndInline')),
      create('div', innerDivStyle, createText('1stBlock')),
      create('span', {}, createText('FourthInline')),
      insertPoint,
      create('div', innerDivStyle, createText('SecondBlock')),
      create('span', {}, createText('Seven777Inline')),
    ]);

    let container2 = create('div', containerStyle, [
      createText('1stInline '),
      createText('ScndInline'),
      create('div', innerDivStyle, createText('1stBlock')),
      createText('FourthInline'),
      create('span', insertedStyle, createText('Inserted new inline')),
      createText('Fifth55Inline'),
      create('div', innerDivStyle, createText('SecondBlock')),
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

    let insertPoint = create('div', innerDivStyle, createText('SecondBlock'));
    let insertBlock = create('span', insertedStyle, createText('Inserted new inline'));

    let container = create('div', containerStyle, [
      create('span', {}, createText('1stInline')),
      create('span', {}, createText('ScndInline')),
      create('div', innerDivStyle, createText('1stBlock')),
      create('span', {}, createText('FourthInline')),
      create('span', {}, createText('Fifth55Inline')),
      insertPoint,
      create('span', {}, createText('Seven777Inline')),
    ]);

    let container2 = create('div', containerStyle, [
      createText('1stInline '),
      createText('ScndInline'),
      create('div', innerDivStyle, createText('1stBlock')),
      createText('FourthInline'),
      createText('Fifth55Inline'),
      create('span', insertedStyle, createText('Inserted new inline')),
      create('div', innerDivStyle, createText('SecondBlock')),
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