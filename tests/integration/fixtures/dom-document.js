/**
 * Test DOM API for
 * - document.createElement
 * - document.createTextNode
 * - document.createComment
 */
it('DOM document', () => {
  const container = document.createElement('div');
  container.appendChild(document.createTextNode('This is a text node.'));
  container.appendChild(document.createComment('This is a comment'));
  document.body.appendChild(container);
});
