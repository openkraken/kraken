/*auto generated*/
describe('multiple-position', () => {
  it('color-stop-conic-2-ref', async () => {
    let div;
    div = createElement('div', {
      style: {
        'box-sizing': 'border-box',
        background:
          'conic-gradient(red 0%, red 25%, blue 25%, blue 75%, green 75%, green 100%)',
        width: '100px',
        height: '100px',
      },
    });
    BODY.appendChild(div);

    await snapshot();

    await snapshot();
  });
  it('color-stop-conic-2', async () => {
    let div;
    div = createElement('div', {
      style: {
        'box-sizing': 'border-box',
        'background-image':
          'conic-gradient(red 0% 25%, blue 25% 75%, green 75% 100%)',
        'background-color': 'orange',
        width: '100px',
        height: '100px',
      },
    });
    BODY.appendChild(div);

    await snapshot();
  });
  it('color-stop-conic', async () => {
    let target;
    target = createElement('div', {
      id: 'target',
      style: {
        width: '100px',
        height: '100px',
        'background-color': 'red',
        'background-image': 'conic-gradient(green 0% 180deg, blue 180deg)',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(target);

    await snapshot();
  });
  it('color-stop-linear-2-ref', async () => {
    let div;
    div = createElement('div', {
      style: {
        'box-sizing': 'border-box',
        background:
          'linear-gradient(to bottom, red 0%, red 25%, blue 25%, blue 75%, red 75%, red 100%)',
        width: '100px',
        height: '100px',
      },
    });
    BODY.appendChild(div);

    await snapshot();
  });
  it('color-stop-linear-2', async () => {
    let div;
    div = createElement('div', {
      style: {
        'box-sizing': 'border-box',
        background:
          'linear-gradient(to bottom, red 0% 25%, blue 25% 75%, red 75% 100%)',
        width: '100px',
        height: '100px',
      },
    });
    BODY.appendChild(div);

    await snapshot();
  });
  it('color-stop-linear', async () => {
    let target;
    target = createElement('div', {
      id: 'target',
      style: {
        width: '100px',
        height: '100px',
        'background-color': 'red',
        'background-image': 'linear-gradient(to right, blue 0% 50%, green 50%)',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(target);

    await snapshot();
  });
  it('color-stop-radial-2-ref', async () => {
    let div;
    div = createElement('div', {
      style: {
        'box-sizing': 'border-box',
        background:
          'radial-gradient(red 0%, red 25%, blue 25%, blue 75%, red 75%, red 100%)',
        width: '100px',
        height: '100px',
      },
    });
    BODY.appendChild(div);

    await snapshot();
  });
  xit('color-stop-radial-2', async () => {
    let div;
    div = createElement('div', {
      '<': '',
      div: '',
      style: {
        'box-sizing': 'border-box',
        background: 'radial-gradient(red 0% 25%, blue 25% 75%, red 75% 100%)',
        width: '100px',
        height: '100px',
      },
    });
    BODY.appendChild(div);

    await snapshot();
  });
  xit('color-stop-radial', async () => {
    let target;
    target = createElement('div', {
      id: 'target',
      style: {
        width: '100px',
        height: '100px',
        'background-color': 'red',
        'background-image':
          'radial-gradient(ellipse 50px 10000px at 0px 50px, blue 0% 50px, green 50px)',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(target);

    await snapshot();
  });
});
