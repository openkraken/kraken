describe('Baseline-rules', () => {
  const wrapperStyle = {
    border: '5px solid black',
    position: 'relative',
    width: '200px',
    height: '150px',
    margin: '10px'
  };

  const boxStyle = {
    border: '10px solid cyan',
    padding: '15px',
    margin: '20px 0px',
    backgroundColor: 'yellow'
  };

  const magentaDottedBorder = {
    'border': '5px solid magenta'
  };

  it('synthesized-baseline-flexbox-001', async () => {
    let wrapper = create('div', wrapperStyle);
    let box = create('div', {
      ...boxStyle,
      display: 'inline-flex'
    });
    append(wrapper, box);
    append(BODY, wrapper);

    await matchScreenshot(wrapper);
  });

  it('synthesized-baseline-flexbox-002', async () => {
    let wrapper = create('div', wrapperStyle);
    let magenta = create('div', {
      ...magentaDottedBorder,
      display: 'inline-block'
    });
    append(wrapper, magenta);
    let box = create('div', {
      ...boxStyle,
      display: 'inline-flex'
    });
    append(magenta, box);
    append(BODY, wrapper);
    await matchScreenshot(wrapper);
  });

  it('synthesized-baseline-flexbox-003', async () => {
    let wrapper = create('div', wrapperStyle);
    let magenta = create('div', {
      ...magentaDottedBorder,
      display: 'inline-block'
    });
    append(wrapper, magenta);
    let box = create('div', {
      ...boxStyle,
      display: 'flex'
    });
    append(magenta, box);
    append(BODY, wrapper);
    await matchScreenshot(wrapper);
  });

  it('synthesized-baseline-flexbox-004', async () => {
    let wrapper = create('div', wrapperStyle);
    let magenta = create('div', {
      ...magentaDottedBorder,
      display: 'inline-flex'
    });
    append(wrapper, magenta);
    let box = create('div', {
      ...boxStyle
    });
    append(magenta, box);
    append(BODY, wrapper);
    await matchScreenshot(wrapper);
  });

  it('synthesized-baseline-flexbox-005', async () => {
    let wrapper = create('div', wrapperStyle);
    let magenta = create('div', {
      ...magentaDottedBorder,
      display: 'inline-block'
    });
    append(wrapper, magenta);
    let box = create('div', {
      ...boxStyle,
      display: 'flex'
    });
    append(magenta, box);
    append(BODY, wrapper);
    await matchScreenshot(wrapper);
  });

  it('synthesized-baseline-flexbox-006', async () => {
    let wrapper = create('div', {
      ...wrapperStyle,
      display: 'flex',
      alignItems: 'baseline'
    });
    let magenta = create('div', {
      ...magentaDottedBorder,
      display: 'inline-flex'
    });
    append(wrapper, magenta);
    let box = create('div', {
      ...boxStyle,
    });
    append(magenta, box);
    append(BODY, wrapper);
    await matchScreenshot(wrapper);
  });

  it('synthesized-baseline-flexbox-007', async () => {
    let wrapper = create('div', {
      ...wrapperStyle,
      display: 'flex',
      alignItems: 'baseline'
    });
    let magenta = create('div', {
      ...magentaDottedBorder,
      display: 'flex'
    });
    append(wrapper, magenta);
    let box = create('div', {
      ...boxStyle,
    });
    append(magenta, box);
    append(BODY, wrapper);
    await matchScreenshot(wrapper);
  });
});

describe('Baseline-rules', () => {

});