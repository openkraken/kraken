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

    let insertPoint = createElementWithStyle('span', {}, createText('1stInline'));
    let container = createElementWithStyle('div', containerStyle, [
      insertPoint,
      createElementWithStyle('div', innerDivStyle, createText('1stBlock')),
      createElementWithStyle('span', {}, createText('FourthInline')),
      createElementWithStyle('span', {}, createText('Fifth55Inline')),
      createElementWithStyle('div', innerDivStyle, createText('SecondBlock')),
      createElementWithStyle('span', {}, createText('Seven777Inline')),
      createElementWithStyle('span', {}, createText('Eight8888Inline')),
    ]);

    let container2 = createElementWithStyle('div', containerStyle, [
      createElementWithStyle('span', insertedStyle, createText('Inserted new inline')),
      createElementWithStyle('span', {}, createText('1stInline')),
      createElementWithStyle('div', innerDivStyle, createText('1stBlock')),
      createElementWithStyle('span', {}, createText('FourthInline')),
      createElementWithStyle('span', {}, createText('Fifth55Inline')),
      createElementWithStyle('div', innerDivStyle, createText('SecondBlock')),
      createElementWithStyle('span', {}, createText('Seven777Inline')),
      createElementWithStyle('span', {}, createText('Eight8888Inline')),
    ]);

    append(BODY, container);
    append(BODY, container2);

    await snapshot();

    container.insertBefore(createElementWithStyle('span', insertedStyle, createText('Inserted new inline')), insertPoint);

    await snapshot();
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

    let insertPoint = createElementWithStyle('span', {}, createText('ScndInline'));
    let container = createElementWithStyle('div', containerStyle, [
      createElementWithStyle('span', {}, createText('1stInline')),
      insertPoint,
      createElementWithStyle('div', innerDivStyle, createText('1stBlock')),
      createElementWithStyle('span', {}, createText('FourthInline')),
      createElementWithStyle('span', {}, createText('Fifth55Inline')),
      createElementWithStyle('div', innerDivStyle, createText('SecondBlock')),
      createElementWithStyle('span', {}, createText('Seven777Inline')),
      createElementWithStyle('span', {}, createText('Eight8888Inline')),
    ]);

    let container2 = createElementWithStyle('div', containerStyle, [
      createElementWithStyle('span', {}, createText('1stInline')),
      createElementWithStyle('span', insertedStyle, createText('Inserted new inline')),
      createElementWithStyle('span', {}, createText('ScndInline')),
      createElementWithStyle('div', innerDivStyle, createText('1stBlock')),
      createText('FourthInline'),
      createText('Fifth55Inline'),
      createElementWithStyle('div', innerDivStyle, createText('SecondBlock')),
      createText('Seven777Inline'),
      createText('Eight8888Inline')
    ]);

    append(BODY, container);
    append(BODY, container2);

    await snapshot();

    container.insertBefore(createElementWithStyle('span', insertedStyle, createText('Inserted new inline')), insertPoint);

    await snapshot();
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

    let insertPoint = createElementWithStyle('div', innerDivStyle, createText('1stBlock'));
    let container = createElementWithStyle('div', containerStyle, [
      createElementWithStyle('span', {}, createText('1stInline')),
      createElementWithStyle('span', {}, createText('ScndInline')),
      insertPoint,
      createElementWithStyle('span', {}, createText('FourthInline')),
      createElementWithStyle('span', {}, createText('Fifth55Inline')),
      createElementWithStyle('div', innerDivStyle, createText('SecondBlock')),
      createElementWithStyle('span', {}, createText('Seven777Inline')),
      createElementWithStyle('span', {}, createText('Eight8888Inline')),
    ]);

    let container2 = createElementWithStyle('div', containerStyle, [
      createText('1stInline '),
      createText('ScndInline'),
      createElementWithStyle('span', insertedStyle, createText('Inserted new inline')),
      createElementWithStyle('div', innerDivStyle, createText('1stBlock')),
      createText('FourthInline'),
      createText('Fifth55Inline'),
      createElementWithStyle('div', innerDivStyle, createText('SecondBlock')),
      createText('Seven777Inline'),
      createText('Eight8888Inline')
    ]);

    append(BODY, container);
    append(BODY, container2);

    await snapshot();

    container.insertBefore(createElementWithStyle('span', insertedStyle, createText('Inserted new inline')), insertPoint);

    await snapshot();
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

    let insertPoint = createElementWithStyle('span', {}, createText('Seven777Inline'));
    let container = createElementWithStyle('div', containerStyle, [
      createElementWithStyle('span', {}, createText('1stInline')),
      createElementWithStyle('span', {}, createText('ScndInline')),
      createElementWithStyle('div', innerDivStyle, createText('1stBlock')),
      createElementWithStyle('span', {}, createText('FourthInline')),
      createElementWithStyle('span', {}, createText('Fifth55Inline')),
      createElementWithStyle('div', innerDivStyle, createText('SecondBlock')),
      insertPoint,
      createElementWithStyle('span', {}, createText('Eight8888Inline')),
    ]);

    let container2 = createElementWithStyle('div', containerStyle, [
      createText('1stInline '),
      createText('ScndInline'),
      createElementWithStyle('div', innerDivStyle, createText('1stBlock')),
      createText('FourthInline'),
      createText('Fifth55Inline'),
      createElementWithStyle('div', innerDivStyle, createText('SecondBlock')),
      createElementWithStyle('span', insertedStyle, createText('Inserted new inline')),
      createText('Seven777Inline'),
      createText('Eight8888Inline')
    ]);

    append(BODY, container);
    append(BODY, container2);

    await snapshot();

    container.insertBefore(createElementWithStyle('span', insertedStyle, createText('Inserted new inline')), insertPoint);

    await snapshot();
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

    let insertPoint = createElementWithStyle('span', {}, createText('Eight8888Inline'));
    let container = createElementWithStyle('div', containerStyle, [
      createElementWithStyle('span', {}, createText('1stInline')),
      createElementWithStyle('span', {}, createText('ScndInline')),
      createElementWithStyle('div', innerDivStyle, createText('1stBlock')),
      createElementWithStyle('span', {}, createText('FourthInline')),
      createElementWithStyle('span', {}, createText('Fifth55Inline')),
      createElementWithStyle('div', innerDivStyle, createText('SecondBlock')),
      createElementWithStyle('span', {}, createText('Seven777Inline')),
      insertPoint,
    ]);

    let container2 = createElementWithStyle('div', containerStyle, [
      createText('1stInline '),
      createText('ScndInline'),
      createElementWithStyle('div', innerDivStyle, createText('1stBlock')),
      createText('FourthInline'),
      createText('Fifth55Inline'),
      createElementWithStyle('div', innerDivStyle, createText('SecondBlock')),
      createText('Seven777Inline'),
      createElementWithStyle('span', insertedStyle, createText('Inserted new inline')),
      createText('Eight8888Inline')
    ]);

    append(BODY, container);
    append(BODY, container2);

    await snapshot();

    container.insertBefore(createElementWithStyle('span', insertedStyle, createText('Inserted new inline')), insertPoint);

    await snapshot();
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

    let container = createElementWithStyle('div', containerStyle, [
      createElementWithStyle('span', {}, createText('1stInline')),
      createElementWithStyle('span', {}, createText('ScndInline')),
      createElementWithStyle('div', innerDivStyle, createText('1stBlock')),
      createElementWithStyle('span', {}, createText('FourthInline')),
      createElementWithStyle('span', {}, createText('Fifth55Inline')),
      createElementWithStyle('div', innerDivStyle, createText('SecondBlock')),
      createElementWithStyle('span', {}, createText('Seven777Inline')),
      createElementWithStyle('span', {}, createText('Eight8888Inline')),
    ]);

    let container2 = createElementWithStyle('div', containerStyle, [
      createText('1stInline '),
      createText('ScndInline'),
      createElementWithStyle('div', innerDivStyle, createText('1stBlock')),
      createText('FourthInline'),
      createText('Fifth55Inline'),
      createElementWithStyle('div', innerDivStyle, createText('SecondBlock')),
      createText('Seven777Inline'),
      createText('Eight8888Inline'),
      createElementWithStyle('span', insertedStyle, createText('Inserted new inline'))
    ]);

    append(BODY, container);
    append(BODY, container2);

    await snapshot();

    container.appendChild(createElementWithStyle('span', insertedStyle, createText('Inserted new inline')));

    await snapshot();
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

    let insertPoint = createElementWithStyle('span', {}, createText('FourthInline'));
    let insertBlock = createElementWithStyle('span', insertedStyle, createText('Inserted new inline'));

    let container = createElementWithStyle('div', containerStyle, [
      createElementWithStyle('span', {}, createText('1stInline')),
      createElementWithStyle('span', {}, createText('ScndInline')),
      createElementWithStyle('div', innerDivStyle, createText('1stBlock')),
      insertPoint,
      createElementWithStyle('span', {}, createText('Fifth55Inline')),
      createElementWithStyle('div', innerDivStyle, createText('SecondBlock')),
      createElementWithStyle('span', {}, createText('Seven777Inline')),
    ]);

    let container2 = createElementWithStyle('div', containerStyle, [
      createText('1stInline '),
      createText('ScndInline'),
      createElementWithStyle('div', innerDivStyle, createText('1stBlock')),
      createElementWithStyle('span', insertedStyle, createText('Inserted new inline')),
      createText('FourthInline'),
      createText('Fifth55Inline'),
      createElementWithStyle('div', innerDivStyle, createText('SecondBlock')),
      createText('Seven777Inline'),
      createText('Eight8888Inline'),
    ]);

    append(BODY, container);
    append(BODY, container2);

    await snapshot();

    container.insertBefore(insertBlock, insertPoint);

    await snapshot();
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

    let insertPoint = createElementWithStyle('span', {}, createText('Fifth55Inline'));
    let insertBlock = createElementWithStyle('span', insertedStyle, createText('Inserted new inline'));

    let container = createElementWithStyle('div', containerStyle, [
      createElementWithStyle('span', {}, createText('1stInline')),
      createElementWithStyle('span', {}, createText('ScndInline')),
      createElementWithStyle('div', innerDivStyle, createText('1stBlock')),
      createElementWithStyle('span', {}, createText('FourthInline')),
      insertPoint,
      createElementWithStyle('div', innerDivStyle, createText('SecondBlock')),
      createElementWithStyle('span', {}, createText('Seven777Inline')),
    ]);

    let container2 = createElementWithStyle('div', containerStyle, [
      createText('1stInline '),
      createText('ScndInline'),
      createElementWithStyle('div', innerDivStyle, createText('1stBlock')),
      createText('FourthInline'),
      createElementWithStyle('span', insertedStyle, createText('Inserted new inline')),
      createText('Fifth55Inline'),
      createElementWithStyle('div', innerDivStyle, createText('SecondBlock')),
      createText('Seven777Inline'),
      createText('Eight8888Inline'),
    ]);

    append(BODY, container);
    append(BODY, container2);

    await snapshot();

    container.insertBefore(insertBlock, insertPoint);

    await snapshot();
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

    let insertPoint = createElementWithStyle('div', innerDivStyle, createText('SecondBlock'));
    let insertBlock = createElementWithStyle('span', insertedStyle, createText('Inserted new inline'));

    let container = createElementWithStyle('div', containerStyle, [
      createElementWithStyle('span', {}, createText('1stInline')),
      createElementWithStyle('span', {}, createText('ScndInline')),
      createElementWithStyle('div', innerDivStyle, createText('1stBlock')),
      createElementWithStyle('span', {}, createText('FourthInline')),
      createElementWithStyle('span', {}, createText('Fifth55Inline')),
      insertPoint,
      createElementWithStyle('span', {}, createText('Seven777Inline')),
    ]);

    let container2 = createElementWithStyle('div', containerStyle, [
      createText('1stInline '),
      createText('ScndInline'),
      createElementWithStyle('div', innerDivStyle, createText('1stBlock')),
      createText('FourthInline'),
      createText('Fifth55Inline'),
      createElementWithStyle('span', insertedStyle, createText('Inserted new inline')),
      createElementWithStyle('div', innerDivStyle, createText('SecondBlock')),
      createText('Seven777Inline'),
      createText('Eight8888Inline'),
    ]);

    append(BODY, container);
    append(BODY, container2);

    await snapshot();

    container.insertBefore(insertBlock, insertPoint);

    await snapshot();
  });
});
