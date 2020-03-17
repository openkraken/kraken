/**
 * Test DOM API for Element:
 * - EventTarget.prototype.addEventListener
 * - EventTarget.prototype.removeEventListener
 * - EventTarget.prototype.dispatchEvent
 */
describe('DOM EventTarget', () => {
  it('should work', async () => {
    return new Promise(async (resolve, reject) => {
      let clickTime = 0;
      const div = document.createElement('div');
      div.appendChild(document.createTextNode('Click: ' + clickTime + 'times.'));

      const clickHandler = () => {
        clickTime++;
        div.replaceChild(
          document.createTextNode('Click: ' + clickTime + 'times.'),
          div.firstChild
        );
      };
      div.addEventListener('click', clickHandler);

      document.body.appendChild(div);
      div.click();
      div.click();

      div.removeEventListener('click', clickHandler);
      div.click(); // Should be `2`.

      setTimeout(() => {
        expect(clickTime === 2).toBe(true);
        await matchScreenshot();
        resolve();
      }, 100);

    });
  });
});
