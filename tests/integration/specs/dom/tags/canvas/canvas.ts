describe('Canvas Tag', () => {
  it('set backgroundColor', async () => {
    let canvas = createElement('canvas', {
      width: '200px',
      height: '200px',
      backgroundColor: 'blue',
    });
    append(BODY, canvas);
    await matchElementImageSnapshot(canvas);
  });

  it('behavior like inline element', async () => {
    let wrapper = createElement('div', {
      width: '200px',
      height: '200px',
    });
    let canvas = createElement('canvas', {
      width: '100px',
      height: '100px',
      backgroundColor: 'blue',
    });
    let text = createElement('span', {}, document.createTextNode('12345'));
    append(wrapper, canvas);
    append(wrapper, text);
    append(BODY, wrapper);
    await matchElementImageSnapshot(wrapper);
  });
});
