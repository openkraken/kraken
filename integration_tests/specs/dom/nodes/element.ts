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
 * - Element.prototype.firstElementChild
 * - Element.prototype.lastElementChild
 * - Element.prototype.insertAdjacentElement
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

  it('should work with string value property', () => {
    let input = document.createElement('input');
    input.value = 'helloworld';
    expect(input.value).toBe('helloworld');
  });

  it('property default to undefined value', () => {
    const el = document.createElement('div');
    expect(typeof el['foo']).toEqual('undefined');

    el['foo'] = 123;
    expect(typeof el['foo']).toEqual('number');
  });

  it('should work with firstElementChild', () => {
    const el = document.createElement('div');
    document.body.appendChild(el);

    el.appendChild(document.createTextNode('text'));
    el.appendChild(document.createComment('comment'));
    for (let i = 0; i < 20; i ++) {
      el.appendChild(document.createElement('span'));
    }

    var target = el.firstElementChild;
    expect(target.tagName).toEqual('SPAN');
  });

  it('should work with lastElementChild', () => {
    const el = document.createElement('div');
    document.body.appendChild(el);

    for (let i = 0; i < 20; i ++) {
      el.appendChild(document.createElement('span'));
    }
    el.appendChild(document.createTextNode('text'));
    el.appendChild(document.createComment('comment'));

    var target = el.lastElementChild;
    expect(target.tagName).toEqual('SPAN');
  });

  // <!-- beforebegin -->
  // <p>
  //   <!-- afterbegin -->
  //   foo
  //   <!-- beforeend -->
  // </p>
  // <!-- afterend -->
  it('insertAdjacentElement should work with beforebegin', () => {
    const root = document.createElement('div');
    document.body.appendChild(root);

    const newElement = document.createElement('p');
    root.insertAdjacentElement('beforebegin', newElement);

    expect(newElement.parentNode).toEqual(root.parentNode);
  });

  it('insertAdjacentElement should work with afterbegin', () => {
    const root = document.createElement('div');
    document.body.appendChild(root);

    const newElement = document.createElement('p');
    root.insertAdjacentElement('afterbegin', newElement);

    expect(newElement.parentNode).toEqual(root);
  });

  it('insertAdjacentElement should work with afterend', () => {
    const root = document.createElement('div');
    document.body.appendChild(root);

    const newElement = document.createElement('p');
    root.insertAdjacentElement('afterend', newElement);

    expect(newElement.parentNode).toEqual(root.parentNode);
  });

  it('insertAdjacentElement should work with beforeend', () => {
    const root = document.createElement('div');
    document.body.appendChild(root);

    const newElement = document.createElement('p');
    root.insertAdjacentElement('beforeend', newElement);

    expect(newElement.parentNode).toEqual(root);
  });
});
