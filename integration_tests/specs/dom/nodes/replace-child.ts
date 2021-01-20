describe('Replace child', () => {
  it('with old child is not an child of parent', () => {
    let container = document.createElement('div');
    let node = document.createElement('div');
    let newChild = document.createElement('div');
    expect(() => {
      container.replaceChild(newChild, node);
    }).toThrowError('Failed to execute \'replaceChild\' on \'Node\': The node to be replaced is not a child of this node.');
  });
  it('with old child is not an type of node', () => {
    let container = document.createElement('div');
    let node = document.createElement('div');
    container.appendChild(node);
    let newChild = document.createElement('div');
    container.replaceChild(newChild, node);
    expect(container.firstChild).toBe(newChild);
    expect(node.parentNode).toBe(null);
    expect(newChild.parentNode).toBe(container);
  });
});
