/**
 * Test DOM API for Element:
 * - Element.prototype.nodeName
 * - Element.prototype.getBoundingClientRect
 * - Element.prototype.setAttribute
 * - Element.prototype.getAttribute
 * - Element.prototype.hasAttribute
 * - Element.prototype.removeAttribute
 * - Element.prototype.click
 * - Element.prototype.toBlob
 */
it('DOM Element', () => {
  const div = document.createElement('div');
  assert(div.nodeName === 'DIV');

  div.style.width = div.style.height = '200px';
  div.style.margin = '20px';
  div.style.backgroundColor = 'grey';
  document.body.appendChild(div);
  const boundingClientRect = JSON.stringify(div.getBoundingClientRect());
  document.body.appendChild(document.createTextNode(boundingClientRect));

  div.setAttribute('foo', 'bar');
  assert(div.getAttribute('foo') === 'bar');
  assert(div.hasAttribute('foo') === true);
  div.removeAttribute('foo');
  assert(div.hasAttribute('foo') === false);
});
