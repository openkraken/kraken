/**
 * Test DOM API for
 * - document.getElementById
 */
describe('Document getElementById', () => {
  it('basic test', () => {
    const div = document.createElement('div');
    div.setAttribute('id', 'div');
    const myDiv = document.getElementById('div');
    expect(myDiv).toBeNull();
  });

  it('not work with element not inserted into Document', () => {
    const div = document.createElement('div');
    div.setAttribute('id', 'div');
    expect(document.getElementById('div')).toBeNull();
  });

  it('not work with not inserted element', () => {
    const div = document.createElement('div');
    div.setAttribute('id', '');
    expect(document.getElementById('')).toBeNull();
  });

  it('work with append and remove', () => {
    const TEST_ID = 'test';
    const div = document.createElement('div');
    div.setAttribute('id', TEST_ID);
    document.body.appendChild(div);
    const result = document.getElementById(TEST_ID);
    expect(result === div).toBeTrue();
    expect(result?.tagName === 'DIV').toBeTrue();

    document.body.removeChild(div);
    const removed = document.getElementById(TEST_ID);
    expect(removed).toBeNull();
  });

  it('work with updating id attribute', () => {
    const OLD_ID = 'test';
    const test = document.createElement('div');
    test.setAttribute('id', OLD_ID);
    document.body.appendChild(test);

    const UPDATE_ID = 'test-updated';
    test.setAttribute('id', UPDATE_ID);
    const updated = document.getElementById(UPDATE_ID);

    const old = document.getElementById(OLD_ID);
    expect(updated === test).toBeTrue();
    expect(old).toBeNull();

    test.removeAttribute('id');
    const removed = document.getElementById(UPDATE_ID);
    expect(removed).toBeNull();
  });

  it('work with multiple elements with the same id', () => {
    const TEST_ID = 'test';
    const PARENT_ID = 'parent';
    const div = document.createElement('div');
    div.setAttribute('id', TEST_ID);
    div.setAttribute('data-name', PARENT_ID);
    document.body.appendChild(div);
    const target = document.getElementById(TEST_ID);
    expect(target?.getAttribute('data-name') === PARENT_ID).toBeTrue();

    const silbingNode = document.createElement('div');
    const SILBING_ID = 'silbing';
    silbingNode.setAttribute('id', TEST_ID);
    silbingNode.setAttribute('data-name', SILBING_ID);
    document.body.appendChild(silbingNode);
    const newTarget = document.getElementById(TEST_ID);
    expect(newTarget).not.toBeNull();
    expect(newTarget?.getAttribute('data-name') === PARENT_ID).toBeTrue();

    newTarget?.parentNode?.removeChild(newTarget);
    const updateTarget = document.getElementById(TEST_ID);
    expect(updateTarget).not.toBeNull();
    expect(updateTarget?.getAttribute('data-name') === SILBING_ID).toBeTrue();
  });

  it('not work with elements inserted into Element', () => {
    const TEST_ID = 'test';
    const child = document.createElement('div');
    child.setAttribute('id', TEST_ID);
    document.createElement('div').appendChild(child);
    expect(document.getElementById(TEST_ID)).toBeNull();
  });

  it('not work with elements inserted into node removed from the tree', () => {
    const TEST_ID = 'test';
    const outer = document.createElement('div');
    const middle = document.createElement('div');
    const inner = document.createElement('div');

    document.body.appendChild(outer);
    outer.appendChild(middle);
    middle.appendChild(inner);
    outer.removeChild(middle);

    const newElement = document.createElement('div');
    newElement.setAttribute('id', TEST_ID);
    inner.appendChild(newElement);
    expect(document.getElementById(TEST_ID)).toBeNull();
  });

  it('work with the same inserted order', () => {
    const TEST_ID = 'test';
    const container = document.createElement('div');
    const element1 = document.createElement('div');
    element1.setAttribute('id', TEST_ID);
    element1.setAttribute('data-order', '1');

    const element2 = document.createElement('div');
    element2.setAttribute('id', TEST_ID);
    element2.setAttribute('data-order', '2');

    const element3 = document.createElement('div');
    element3.setAttribute('id', TEST_ID);
    element3.setAttribute('data-order', '3');

    const element4 = document.createElement('div');
    element4.setAttribute('id', TEST_ID);
    element4.setAttribute('data-order', '4');

    document.body.appendChild(container);
    container.appendChild(element2);
    container.appendChild(element4);
    container.insertBefore(element3, element4);
    container.insertBefore(element1, element2);

    let test = document.getElementById(TEST_ID);
    expect(test === element1).toBeTrue();
    container.removeChild(element1);

    test = document.getElementById(TEST_ID);
    expect(test === element2).toBeTrue();
    container.removeChild(element2);

    test = document.getElementById(TEST_ID);
    expect(test === element3).toBeTrue();
    container.removeChild(element3);

    test = document.getElementById(TEST_ID);
    expect(test === element4).toBeTrue();
    container.removeChild(element4);
  });
});
