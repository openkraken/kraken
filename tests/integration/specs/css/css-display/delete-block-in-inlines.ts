describe('delete-block-in-inlines', () => {
  it('beginning-001', async (done) => {
    let containerStyle = {
      backgroundColor: 'fuchsia',
      color: 'black',
      font: '20px',
      margin: '1em'
    };
    let container = create('div', containerStyle);
    let container2 = create('div', containerStyle);

    let nodeToDelete = create('div', {
      borderLeft: 'yellow solid 0.5em',
      borderRight: 'yellow solid 0.5em',
      margin: '1em 0em'
    }, createText('block to remove'));

    BODY.addEventListener('click', async () => {
      container.removeChild(nodeToDelete);
      await matchScreenshot();
      done();
    });

    append(container, nodeToDelete);
    append(container, create('span', {}, createText('Several')));
    append(container, create('span', {}, createText('inline elements')));
    append(container, createText(' are '));
    append(container, create('span', {}, createText('in this')));
    append(container, createText(' sentence.'));

    append(container2, createText('Several inline elements are in this sentence.'));

    append(BODY, container);
    append(BODY, container2);
    await matchScreenshot();

    BODY.click();
  });

  fit('end-001', async (done) => {
    let containerStyle = {
      backgroundColor: 'fuchsia',
      color: 'black',
      font: '20px',
      margin: '1em'
    };
    let container = create('div', containerStyle);
    let container2 = create('div', containerStyle);

    let nodeToDelete = create('div', {
      borderLeft: 'yellow solid 0.5em',
      borderRight: 'yellow solid 0.5em',
      margin: '1em 0em'
    }, createText('block to remove'));

    BODY.addEventListener('click', async () => {
      container.removeChild(nodeToDelete);
      await matchScreenshot();
      done();
    });

    append(container, create('span', {}, createText('Several')));
    append(container, create('span', {}, createText('inline elements')));
    append(container, createText(' are '));
    append(container, create('span', {}, createText('in this')));
    append(container, createText(' sentence.'));

    append(container2, createText('Several inline elements are in this sentence.'));
    append(container, nodeToDelete);

    append(BODY, container);
    append(BODY, container2);
    await matchScreenshot();

    BODY.click();
  });

  fit('middle-001', async (done) => {
    let containerStyle = {
      backgroundColor: 'fuchsia',
      color: 'black',
      font: '20px',
      margin: '1em'
    };
    let container = create('div', containerStyle);
    let container2 = create('div', containerStyle);

    let nodeToDelete = create('div', {
      borderLeft: 'yellow solid 0.5em',
      borderRight: 'yellow solid 0.5em',
      margin: '1em 0em'
    }, createText('block to remove'));

    BODY.addEventListener('click', async () => {
      container.removeChild(nodeToDelete);
      await matchScreenshot();
      done();
    });

    append(container, create('span', {}, createText('Several')));
    append(container, create('span', {}, createText('inline elements')));
    append(container, createText(' are '));
    append(container, nodeToDelete);
    append(container, create('span', {}, createText('in this')));
    append(container, createText(' sentence.'));

    append(container2, createText('Several inline elements are in this sentence.'));

    append(BODY, container);
    append(BODY, container2);
    await matchScreenshot();

    BODY.click();
  });
});