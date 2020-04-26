/*auto generated*/
describe('position-fixed', () => {
  it('at-bottom-right-on-viewport', async () => {
    let div;
    let target;
    div = createElement('div', {
      'box-sizing': 'border-box',
      width: '200%',
      height: '200%',
    });
    target = createElement('div', {
      position: 'fixed',
      bottom: '0',
      right: '0',
      'background-color': 'green',
      width: '100px',
      height: '100px',
      'box-sizing': 'border-box',
    });
    BODY.appendChild(div);
    BODY.appendChild(target);

    await matchScreenshot();
  });
});
