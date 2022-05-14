/**
 * Test DOM API for
 * - document.getElementsByName
 */
describe('Document getElementsByName', () => {
  it('basic test', () => {
    const element = document.createElement('div');
    element.setAttribute('name', 'foo');
    document.body.appendChild(element);

    const nodeList = document.getElementsByName('foo');
    expect(nodeList.length).toBe(1);
    expect(nodeList[0]).toEqual(element);
  });
});
