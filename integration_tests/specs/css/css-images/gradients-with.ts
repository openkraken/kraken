/*auto generated*/
describe('gradients-with', () => {
  it('border', async () => {
    let gradient1;
    let gradient2;
    let gradient3;
    gradient1 = createElement('div', {
      id: 'gradient1',
      class: 'test',
      style: {
        width: '200px',
        height: '100px',
        border: '10px solid blue',
        'border-left-width': '100px',
        'background-image':
          'linear-gradient(to right top, black 49%, white 50%)',
        'box-sizing': 'border-box',
      },
    });
    gradient2 = createElement('div', {
      id: 'gradient2',
      class: 'test',
      style: {
        width: '200px',
        height: '100px',
        border: '10px solid blue',
        'margin-left': '90px',
        'background-image':
          'linear-gradient(to right top, black 49%, white 50%)',
        'box-sizing': 'border-box',
      },
    });
    gradient3 = createElement('div', {
      id: 'gradient3',
      class: 'test',
      style: {
        width: '200px',
        height: '100px',
        border: '10px solid blue',
        'border-left-width': '100px',
        'background-image':
          'radial-gradient(circle at 30% 30%, black 49%, white 50%)',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(gradient1);
    BODY.appendChild(gradient2);
    BODY.appendChild(gradient3);

    await snapshot();
  });
  it('transparent-ref', async () => {
    let p;
    let gradient1;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Gradient using 'transparent'`)]
    );
    gradient1 = createElement('div', {
      id: 'gradient1',
      class: 'test gradient',
      style: {
        width: '200px',
        height: '100px',
        'margin-left': '90px',
        'background-image':
          'linear-gradient(to left, blue 0%, blue 20%, rgba(0,0,255,0))',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(gradient1);

    await snapshot();
  });
  it('transparent', async () => {
    let p;
    let p_1;
    let gradient1;
    let gradient2;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Gradient using 'transparent'`)]
    );
    gradient1 = createElement('div', {
      id: 'gradient1',
      class: 'test',
      style: {
        width: '200px',
        height: '100px',
        'margin-left': '90px',
        'background-image':
          'linear-gradient(to left, blue 0%, blue 20%, transparent)',
        'box-sizing': 'border-box',
      },
    });
    p_1 = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Gradient using rgba(0,0,255,0)`)]
    );
    gradient2 = createElement('div', {
      id: 'gradient2',
      class: 'test',
      style: {
        width: '200px',
        height: '100px',
        'margin-left': '90px',
        'background-image':
          'linear-gradient(to left, blue 0%, blue 20%, rgba(0,0,0,0))',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(p_1);
    BODY.appendChild(gradient1);
    BODY.appendChild(gradient2);

    await snapshot();
  });
});
