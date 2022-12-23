// @TODO: Support getComputedStyle.
xdescribe('background-331', () => {
  const divStyle = {
    background: 'red',
  };
  it('background initial value for background-image', async () => {
    let div = createElementWithStyle('div', divStyle);
    append(BODY, div);
    let cs = window.getComputedStyle(div, null);
    expect(cs.getPropertyValue('background-image')).toBe('none');
  });

  it('background initial value for background-position', async () => {
    let div = createElementWithStyle('div', divStyle);
    append(BODY, div);
    let cs = window.getComputedStyle(div, null);
    expect(cs.getPropertyValue('background-position')).toBe('0% 0%');
  });

  it('background initial value for background-size', async () => {
    let div = createElementWithStyle('div', divStyle);
    append(BODY, div);
    let cs = window.getComputedStyle(div, null);
    expect(cs.getPropertyValue('background-size')).toBe('auto');
  });

  it('background initial value for background-repeat', async () => {
    let div = createElementWithStyle('div', divStyle);
    append(BODY, div);
    let cs = window.getComputedStyle(div, null);
    expect(cs.getPropertyValue('background-repeat')).toBe('repeat');
  });

  it('background initial value for background-attachment', async () => {
    let div = createElementWithStyle('div', divStyle);
    append(BODY, div);
    let cs = window.getComputedStyle(div, null);
    expect(cs.getPropertyValue('background-attachment')).toBe('scroll');
  });

  it('background initial value for background-origin', async () => {
    let div = createElementWithStyle('div', divStyle);
    append(BODY, div);
    let cs = window.getComputedStyle(div, null);
    expect(cs.getPropertyValue('background-origin')).toBe('padding-box');
  });

  it('background initial value for background-clip', async () => {
    let div = createElementWithStyle('div', divStyle);
    append(BODY, div);
    let cs = window.getComputedStyle(div, null);
    expect(cs.getPropertyValue('background-clip')).toBe('border-box');
  });

  it('background initial value for background-color', async () => {
    let div = createElementWithStyle('div', divStyle);
    append(BODY, div);
    let cs = window.getComputedStyle(div, null);
    expect(cs.getPropertyValue('background-color')).toBe('rgba(255, 0, 0, 0)');
  });

  it('background url should distinguish word capitalize', async (done) => {
    let div = document.createElement('div');
    div.style.width = '100px';
    div.style.height = '100px';
    div.style.backgroundImage = 'URL(https://gw.alicdn.com/tfs/TB1E5GzToz1gK0jSZLeXXb9kVXa-750-595.png)';
    document.body.appendChild(div);
    await snapshot(1);
  });
});
