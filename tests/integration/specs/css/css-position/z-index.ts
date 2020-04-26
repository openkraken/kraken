/*auto generated*/
describe('z-index', () => {
  it('blend-will-change-overlapping-layers', async () => {
    let div;
    let div_1;
    div = createElement(
      'div',
      {
        'box-sizing': 'border-box',
        'z-index': '1',
        position: 'relative',
        height: '50vh',
      },
      [
        createElement('div', {
          'box-sizing': 'border-box',
          'will-change': 'transform',
          position: 'absolute',
          bottom: '-100px',
          width: '100px',
          height: '100px',
          'background-color': 'red',
        }),
      ]
    );
    div_1 = createElement('div', {
      'box-sizing': 'border-box',
      'z-index': '1',
      position: 'relative',
      'background-color': 'green',
      height: '100px',
    });
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        // window.scrollBy(0, 100);
        // takeScreenshot();
      });
    });

    await matchScreenshot();
  });
});
