describe('Display inline-block', () => {
  it('should work with basic samples', async () => {
    const container = document.createElement('div');
    setStyle(container, {
      width: '100px',
      height: '100px',
      display: 'inline-block',
      backgroundColor: '#666',
    });

    document.body.appendChild(container);
    document.body.appendChild(
      document.createTextNode(
        'This text should display as the same line as the box'
      )
    );

    await matchScreenshot();
  });

  xit('inline-block box constraint is tight', async () => {
    let magenta = create('div', {
      border: '5px solid magenta',
      display: 'inline-block',
    });
    // append(wrapper, magenta);
    let box = create('div', {
      border: '10px solid cyan',
      padding: '15px',
      margin: '20px 0px',
      backgroundColor: 'yellow',
      display: 'inline-flex',
    });
    append(magenta, box);
    append(BODY, magenta);
    await matchScreenshot();
  });

  xit('inline-block nest inline-block should behavior like inline-block', async () => {
    let magenta = create('div', {
      border: '5px solid magenta',
      display: 'inline-block',
    });
    let box = create('div', {
      border: '10px solid cyan',
      padding: '15px',
      margin: '20px 0px',
      backgroundColor: 'yellow',
      display: 'inline-block',
    });
    append(magenta, box);
    append(BODY, magenta);
    await matchElementImageSnapshot(magenta);
  });

  xit('inline-block nest block should behavior like inline-block', async () => {
    let magenta = create('div', {
      border: '5px solid magenta',
      display: 'inline-block',
    });
    let box = create('div', {
      border: '10px solid cyan',
      padding: '15px',
      margin: '20px 0px',
      backgroundColor: 'yellow',
      display: 'block',
    });
    append(magenta, box);
    append(BODY, magenta);
    await matchElementImageSnapshot(magenta);
  });

  xit('textNode only if have one space', async () => {
    let containerStyle = {
      backgroundColor: 'fuchsia',
      color: 'black',
      font: '20px',
      margin: '10px'
    };

    let divStyle = {
      display: 'inline-block'
    };

    let container = create('div', containerStyle, [
      create('div', divStyle, createText('Several ')),
      create('div', divStyle, createText(' inline elements')),
      createText(' are '),
      create('div', divStyle, createText('in this')),
      createText(' sentence.')
    ]);

    let container2 = create('div', containerStyle, [
      createText('Several inline elements are in this sentence.')
    ]);

    append(BODY, container);
    append(BODY, container2);

    await matchScreenshot();
  });
});
