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
describe('DOM Element API', () => {
  it('should work', () => {
    const div = document.createElement('div');
    expect(div.nodeName === 'DIV').toBeTrue();

    div.style.width = div.style.height = '200px';
    div.style.border = '1px solid red';
    div.style.padding = '10px';
    div.style.margin = '20px';
    div.style.backgroundColor = 'grey';
    document.body.appendChild(div);

    const boundingClientRect = div.getBoundingClientRect();
    expect(JSON.parse(JSON.stringify(boundingClientRect))).toEqual({
      x: 20.0,
      y: 20.0,
      width: 200.0,
      height: 200.0,
      top: 20.0,
      left: 20.0,
      right: 220.0,
      bottom: 220.0,
    } as any);

    div.setAttribute('foo', 'bar');
    expect(div.getAttribute('foo')).toBe('bar');
    expect(div.hasAttribute('foo')).toBeTrue();

    div.removeAttribute('foo');
    expect(div.hasAttribute('foo')).toBeFalse();
  });

  it('children should only contain elements', () => {
    let container = document.createElement('div');
    let a = document.createElement('div');
    let b = document.createElement('div');
    let text = document.createTextNode('test');
    let comment = document.createTextNode('#comment');
    container.appendChild(a);
    container.appendChild(text);
    container.appendChild(b);
    container.appendChild(comment);

    expect(container.childNodes.length).toBe(4);
    expect(container.children.length).toBe(2);
    expect(container.children[0]).toBe(a);
    expect(container.children[1]).toBe(b);
  });
});
