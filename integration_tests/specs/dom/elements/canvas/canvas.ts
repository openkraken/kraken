describe('Canvas Tag', () => {
  it('set backgroundColor', async () => {
    let canvas = createElementWithStyle('canvas', {
      width: '200px',
      height: '200px',
      backgroundColor: 'blue',
    });
    append(BODY, canvas);
    await snapshot(canvas);
  });

  it('behavior like inline element', async () => {
    let wrapper = createElementWithStyle('div', {
      width: '200px',
      height: '200px',
    });
    let canvas = createElementWithStyle('canvas', {
      width: '100px',
      height: '100px',
      backgroundColor: 'blue',
    });
    let text = createElementWithStyle('span', {}, document.createTextNode('12345'));
    append(wrapper, canvas);
    append(wrapper, text);
    append(BODY, wrapper);
    await snapshot(wrapper);
  });
});
