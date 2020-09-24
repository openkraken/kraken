describe('Baseline-rules flexbox', () => {
  const wrapperStyle = {
    border: '5px solid black',
    position: 'relative',
    width: '200px',
    height: '150px',
    margin: '10px',
  };

  const inlineBoxStyle = {
    width: '50px',
    height: '50px',
    backgroundColor: 'blue',
    display: 'inline-block',
  };

  const boxStyle = {
    border: '10px solid cyan',
    padding: '15px',
    margin: '20px 0px',
    backgroundColor: 'yellow',
  };

  const magentaDottedBorder = {
    border: '5px solid magenta',
  };

  it('synthesized-baseline-flexbox-001', async () => {
    let wrapper = createElementWithStyle('div', wrapperStyle);
    let canvas = createElementWithStyle('div', inlineBoxStyle);
    append(wrapper, canvas);
    let box = createElementWithStyle('div', {
      ...boxStyle,
      display: 'inline-flex',
    });
    append(wrapper, box);
    append(BODY, wrapper);

    await matchElementImageSnapshot(wrapper);
  });

  it('synthesized-baseline-flexbox-002', async () => {
    let wrapper = createElementWithStyle('div', wrapperStyle);
    let canvas = createElementWithStyle('div', inlineBoxStyle);
    append(wrapper, canvas);
    let magenta = createElementWithStyle('div', {
      ...magentaDottedBorder,
      display: 'inline-block',
    });
    append(wrapper, magenta);
    let box = createElementWithStyle('div', {
      ...boxStyle,
      display: 'inline-flex',
    });
    append(magenta, box);
    append(BODY, wrapper);
    await matchViewportSnapshot();
  });

  it('synthesized-baseline-flexbox-003', async () => {
    let wrapper = createElementWithStyle('div', wrapperStyle);
    let canvas = createElementWithStyle('div', inlineBoxStyle);
    append(wrapper, canvas);
    let magenta = createElementWithStyle('div', {
      ...magentaDottedBorder,
      display: 'inline-block',
    });
    append(wrapper, magenta);
    let box = createElementWithStyle('div', {
      ...boxStyle,
      display: 'flex',
    });
    append(magenta, box);
    append(BODY, wrapper);
    await matchElementImageSnapshot(wrapper);
  });

  it('synthesized-baseline-flexbox-004', async () => {
    let wrapper = createElementWithStyle('div', wrapperStyle);
    let canvas = createElementWithStyle('div', inlineBoxStyle);
    append(wrapper, canvas);
    let magenta = createElementWithStyle('div', {
      ...magentaDottedBorder,
      display: 'inline-flex',
    });
    append(wrapper, magenta);
    let box = createElementWithStyle('div', {
      ...boxStyle,
    });
    append(magenta, box);
    append(BODY, wrapper);
    await matchElementImageSnapshot(wrapper);
  });

  it('synthesized-baseline-flexbox-005', async () => {
    let wrapper = createElementWithStyle('div', wrapperStyle);
    let canvas = createElementWithStyle('div', inlineBoxStyle);
    append(wrapper, canvas);
    let magenta = createElementWithStyle('div', {
      ...magentaDottedBorder,
      display: 'inline-block',
    });
    append(wrapper, magenta);
    let box = createElementWithStyle('div', {
      ...boxStyle,
      display: 'flex',
    });
    append(magenta, box);
    append(BODY, wrapper);
    await matchElementImageSnapshot(wrapper);
  });

  it('synthesized-baseline-flexbox-006', async () => {
    let wrapper = createElementWithStyle('div', {
      ...wrapperStyle,
      display: 'flex',
      alignItems: 'baseline',
    });
    let canvas = createElementWithStyle('div', inlineBoxStyle);
    append(wrapper, canvas);
    let magenta = createElementWithStyle('div', {
      ...magentaDottedBorder,
      display: 'inline-flex',
    });
    append(wrapper, magenta);
    let box = createElementWithStyle('div', {
      ...boxStyle,
    });
    append(magenta, box);
    append(BODY, wrapper);
    await matchElementImageSnapshot(wrapper);
  });

  it('synthesized-baseline-flexbox-007', async () => {
    let wrapper = createElementWithStyle('div', {
      ...wrapperStyle,
      display: 'flex',
      alignItems: 'baseline',
    });
    let canvas = createElementWithStyle('div', inlineBoxStyle);
    append(wrapper, canvas);
    let magenta = createElementWithStyle('div', {
      ...magentaDottedBorder,
      display: 'flex',
    });
    append(wrapper, magenta);
    let box = createElementWithStyle('div', {
      ...boxStyle,
    });
    append(magenta, box);
    append(BODY, wrapper);
    await matchElementImageSnapshot(wrapper);
  });
});

// @TODO: deps on inline-block features.
// describe('Baseline-rules inline-block', () => {
//   const wrapperStyle = {
//     border: '1px solid block',
//     position: 'relative',
//     width: '200px',
//     height: '150px',
//     margin: '10px'
//   };
//
//   const canvasStyle = {
//     width: '50px',
//     height: '50px',
//     backgroundColor: 'blue'
//   };
//
//   const magentaBorderStyle = {
//     border: '5px solid magenta'
//   };
//
//   const borderPaddingMargin = {
//     border: '10px solid cyan',
//     padding: '15px',
//     margin: '20px 0px',
//     backgroundColor: 'yellow'
//   };
//
//   xit('synthesized-baseline-inline-block-001', async () => {
//     let wrapper = create('div', wrapperStyle);
//     let left = create('canvas', canvasStyle);
//     let box = create('div', {
//       borderPaddingMargin,
//       display: 'inline-flex'
//     });
//     append(wrapper, left);
//     append(wrapper, box);
//     append(BODY, wrapper);
//     await matchViewportSnapshot();
//   });
// });
