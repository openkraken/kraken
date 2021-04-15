/*auto generated*/
describe('hypothetical-dynamic', () => {
  it('change-001-ref', async () => {
    let ancestor;
    ancestor = createElementWithStyle('div', {
      width: '100px',
      height: '100px',
      position: 'fixed',
      left: '100px',
      top: '0',
      'background-color': 'green',
    });
    BODY.appendChild(ancestor);

    await snapshot();
  });
  it('change-001', async () => {
    let child;
    let ancestor;
    ancestor = createElementWithStyle(
      'div',
      {
        position: 'fixed',
        width: '100px',
        height: '100px',
        'background-color': 'red',
        left: '100px',
        top: '0',
      },
      [
        (child = createElementWithStyle('div', {
          position: 'fixed',
          width: '100px',
          height: '100px',
          'background-color': 'green',
        })),
      ]
    );
    BODY.appendChild(ancestor);

    await snapshot();

    ancestor.style.left = '100px';

    await snapshot();
  });
  it('change-002', async () => {
    let child;
    let ancestor;
    ancestor = createElementWithStyle(
      'div',
      {
        width: '100px',
        height: '100px',
        'background-color': 'red',
        position: 'absolute',
        left: '100px',
        top: '0',
      },
      [
        (child = createElementWithStyle('div', {
          width: '100px',
          height: '100px',
          'background-color': 'green',
          position: 'fixed',
        })),
      ]
    );
    BODY.appendChild(ancestor);

    await snapshot();

    ancestor.style.left = '100px';

    await snapshot();
  });
  it('change-003', async () => {
    let child;
    let ancestor;
    ancestor = createElementWithStyle(
      'div',
      {
        width: '100px',
        height: '100px',
        'background-color': 'red',
        position: 'relative',
        left: '100px',
        top: '0',
      },
      [
        (child = createElementWithStyle('div', {
          width: '100px',
          height: '100px',
          'background-color': 'green',
          position: 'fixed',
        })),
      ]
    );
    BODY.appendChild(ancestor);

    await snapshot();
    ancestor.style.left = '100px';

    await snapshot();

    await snapshot();
  });
});
