xdescribe('background-331', () => {
  const divStyle = {
    background: 'red',
  };
  it('background initial value for background-image', async () => {
    let div = create('div', divStyle);
    append(BODY, div);
    let cs = window.getComputedStyle(div, null);
    expect(cs.getPropertyValue('background-image')).toBe('none');
  });

  it('background initial value for background-position', async () => {
    let div = create('div', divStyle);
    append(BODY, div);
    let cs = window.getComputedStyle(div, null);
    expect(cs.getPropertyValue('background-position')).toBe('0% 0%');
  });

  it('background initial value for background-size', async () => {
    let div = create('div', divStyle);
    append(BODY, div);
    let cs = window.getComputedStyle(div, null);
    expect(cs.getPropertyValue('background-size')).toBe('auto');
  });

  it('background initial value for background-repeat', async () => {
    let div = create('div', divStyle);
    append(BODY, div);
    let cs = window.getComputedStyle(div, null);
    expect(cs.getPropertyValue('background-repeat')).toBe('repeat');
  });

  it('background initial value for background-attachment', async () => {
    let div = create('div', divStyle);
    append(BODY, div);
    let cs = window.getComputedStyle(div, null);
    expect(cs.getPropertyValue('background-attachment')).toBe('scroll');
  });

  it('background initial value for background-origin', async () => {
    let div = create('div', divStyle);
    append(BODY, div);
    let cs = window.getComputedStyle(div, null);
    expect(cs.getPropertyValue('background-origin')).toBe('padding-box');
  });

  it('background initial value for background-clip', async () => {
    let div = create('div', divStyle);
    append(BODY, div);
    let cs = window.getComputedStyle(div, null);
    expect(cs.getPropertyValue('background-clip')).toBe('border-box');
  });

  it('background initial value for background-color', async () => {
    let div = create('div', divStyle);
    append(BODY, div);
    let cs = window.getComputedStyle(div, null);
    expect(cs.getPropertyValue('background-color')).toBe('rgba(255, 0, 0, 0)');
  });
});
