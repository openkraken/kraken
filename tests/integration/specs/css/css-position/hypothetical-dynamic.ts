/*auto generated*/
describe('hypothetical-dynamic', () => {
  it('change-001-ref', async () => {
    let ancestor;
    ancestor = createElement('div', {
      width: '100px',
      height: '100px',
      position: 'fixed',
      left: '100px',
      top: '0',
      'background-color': 'green',
    });
    BODY.appendChild(ancestor);

    await matchScreenshot();
  });
  it('change-001', async () => {
    let child;
    let ancestor;
    ancestor = createElement(
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
        (child = createElement('div', {
          position: 'fixed',
          width: '100px',
          height: '100px',
          'background-color': 'green',
        })),
      ]
    );
    BODY.appendChild(ancestor);

    await matchScreenshot();

    ancestor.style.left = '100px';

    await matchScreenshot();
  });
  it('change-002', async () => {
    let child;
    let ancestor;
    ancestor = createElement(
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
        (child = createElement('div', {
          width: '100px',
          height: '100px',
          'background-color': 'green',
          position: 'fixed',
        })),
      ]
    );
    BODY.appendChild(ancestor);

    await matchScreenshot();

    ancestor.style.left = '100px';

    await matchScreenshot();
  });
  xit('change-003', async () => {
    let child;
    let ancestor;
    ancestor = createElement(
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
        (child = createElement('div', {
          width: '100px',
          height: '100px',
          'background-color': 'green',
          position: 'fixed',
        })),
      ]
    );
    BODY.appendChild(ancestor);

    await matchScreenshot();
    ancestor.style.left = '100px';

    await matchScreenshot();

    await matchScreenshot();
  });
});
