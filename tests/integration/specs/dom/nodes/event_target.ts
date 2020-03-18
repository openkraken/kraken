/**
 * Test DOM API for Element:
 * - EventTarget.prototype.addEventListener
 * - EventTarget.prototype.removeEventListener
 * - EventTarget.prototype.dispatchEvent
 */
describe('DOM EventTarget', () => {
  it('should work', async () => {
    let clickTime = 0;
    const div = document.createElement('div');

    const clickHandler = () => {
      clickTime++;
    };
    div.addEventListener('click', clickHandler);

    document.body.appendChild(div);
    div.click();
    div.click();

    div.removeEventListener('click', clickHandler);
    div.click();

    // Only 2 times recorded.
    expect(clickTime).toBe(2);
  });
});
