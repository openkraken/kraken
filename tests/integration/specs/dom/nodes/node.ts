/**
 * Test DOM API for Element:
 * - Node.prototype.isConnected
 * - Node.prototype.firstChild
 * - Node.prototype.lastChild
 * - Node.prototype.previousSibling
 * - Node.prototype.nextSibling
 * - Node.prototype.appendChild
 * - Node.prototype.removeChild
 * - Node.prototype.insertBefore
 * - Node.prototype.replaceChild
 * - ChildNode.prototype.remove
 */
describe('Node API', () => {
  it('should work', async () => {
    const el = document.createElement('div');
    expect(el.isConnected === false).toBe(true);
    document.body.appendChild(el);
    expect(el.isConnected === true).toBe(true);

    const child_0 = document.createTextNode('first child');
    el.appendChild(child_0);
    expect(el.firstChild === child_0).toBe(true);
    expect(el.lastChild === child_0).toBe(true);

    const child_1 = document.createTextNode('second child');
    el.appendChild(child_1);
    expect(child_1.previousSibling === child_0).toBe(true);
    expect(child_0.nextSibling === child_1).toBe(true);

    el.removeChild(child_0);
    const child_2 = document.createTextNode('third child');

    el.insertBefore(child_2, child_1);
    const child_3 = document.createTextNode('fourth child');
    el.replaceChild(child_3, child_1);

    await matchViewportSnapshot();
  });

  it('ChildNode.prototype.remove', () => {
    const el = document.createElement('div');
    document.body.appendChild(el);

    expect(el.isConnected).toEqual(true);

    el.remove();

    expect(el.isConnected).toEqual(false);
  });
});
