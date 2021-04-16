/*auto generated*/
describe('fixed-z', () => {
  it('index-blend', async () => {
    let background;
    let text;
    background = createElementWithStyle('div', {
      position: 'fixed',
      'z-index': '1',
      top: '0',
      left: '0',
      bottom: '0',
      right: '0',
      opacity: '1',
    });
    text = createElementWithStyle(
      'div',
      {
        position: 'relative',
        'z-index': '3',
        overflow: 'hidden',
        width: '360px',
        'min-height': '640px',
        'font-size': '50px',
      },
      [
        createElementWithStyle('div', {
          width: '100px',
          height: '50px',
        }),
        createElementWithStyle('div', {
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

    await snapshot();
  });
  it('index-blend-ref', async () => {
    let div;
    let div_1;
    div = createElementWithStyle('div', {
      width: '100px',
      height: '400px',
    });
    div_1 = createElementWithStyle('div', {
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

    await snapshot();
  });
});
