/*auto generated*/
describe('fixed-z', () => {
  it('index-blend', async () => {
    let background;
    let text;
    background = createElement('div', {
      position: 'fixed',
      'z-index': '1',
      top: '0',
      left: '0',
      bottom: '0',
      right: '0',
      opacity: '1',
    });
    text = createElement(
      'div',
      {
        position: 'relative',
        'z-index': '3',
        overflow: 'hidden',
        width: '100vw',
        'min-height': '100vh',
        'font-size': '50px',
      },
      [
        createElement('div', {
          width: '100px',
          height: '50px',
        }),
        createElement('div', {
          'background-color': 'green',
          width: '100px',
          height: '100px',
        }),
      ]
    );
    BODY.appendChild(background);
    BODY.appendChild(text);

    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        // window.scrollBy(0, 3000);
        // takeScreenshot();
      });
    });

    await matchScreenshot();
  });
  it('index-blend-ref', async () => {
    let div;
    let div_1;
    div = createElement('div', {
      width: '100px',
      height: '400px',
    });
    div_1 = createElement('div', {
      'background-color': 'green',
      width: '100px',
      height: '100px',
    });
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        // window.scrollBy(0, 3000);
      });
    });

    await matchScreenshot();
  });
});
