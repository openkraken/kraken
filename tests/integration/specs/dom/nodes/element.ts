/**
 * Test DOM API for
 * - Element.prototype.nodeName
 * - Element.prototype.getBoundingClientRect
 * - Element.prototype.setAttribute
 * - Element.prototype.getAttribute
 * - Element.prototype.hasAttribute
 * - Element.prototype.removeAttribute
 * - Element.prototype.click
 * - Element.prototype.toBlob
 */
describe('Element api', () => {
  it('should work', async () => {
    const div = document.createElement('div');
    expect(div.nodeName === 'DIV').toBe(true);

    div.style.width = div.style.height = '200px';
    div.style.margin = '20px';
    div.style.backgroundColor = 'grey';
    document.body.appendChild(div);
    const boundingClientRect = JSON.stringify(div.getBoundingClientRect());
    document.body.appendChild(document.createTextNode(boundingClientRect));

    div.setAttribute('foo', 'bar');
    expect(div.getAttribute('foo') === 'bar').toBe(true);
    expect(div.hasAttribute('foo') === true).toBe(true);
    div.removeAttribute('foo');
    expect(div.hasAttribute('foo') === false).toBe(true);

    await matchScreenshot();
  });
});
