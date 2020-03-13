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
 */
it('DOM Node', () => {
  const el = document.createElement('div');
  assert(el.isConnected === false);
  document.body.appendChild(el);
  assert(el.isConnected === true);

  const child_0 = document.createTextNode('first child');
  el.appendChild(child_0);
  assert(el.firstChild === child_0);
  assert(el.lastChild === child_0);

  const child_1 = document.createTextNode('second child');
  el.appendChild(child_1);
  assert(child_1.previousSibling === child0);
  assert(child_0.nextSibling === child1);

  el.removeChild(child_0);
  const child_2 = document.createTextNode('third child');

  el.insertBefore(child_2, child_1);
  const child_3 = document.createTextNode('fourth child');
  el.replaceChild(child_3, child_1);
});
