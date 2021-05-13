/**
 * Test DOM API for
 * - document.getElementsByTagName
 */
describe('Document getElementsByTagName', () => {
  it('basic test', () => {
    const element = document.createElement('div');
    BODY.appendChild(element);
    expect(document.getElementsByTagName('div').length).toBe(1);
  });

  it('work with a element', () => {
    const container = document.createElement('div');
    BODY.appendChild(container);

    const element = document.createElement('a');
    container.appendChild(element);

    expect(document.getElementsByTagName('a').length).toBe(1);
  });

  it('work with elements', () => {
    const container = document.createElement('div');
    BODY.appendChild(container);

    const element1 = document.createElement('span');
    const element2 = document.createElement('span');
    container.appendChild(element1);
    container.appendChild(element2);

    expect(document.getElementsByTagName('span').length).toBe(2);
  });

  it('not work with not inserted element', () => {
    const element = document.createElement('div');
    expect(document.getElementsByTagName('div').length).toBe(0);
  });

  it('work with upper case', () => {
    const element = document.createElement('div');
    BODY.appendChild(element);

    expect(document.getElementsByTagName('DIV').length).toBe(1);
  });

  it('work with upper case and low case', () => {
    const element = document.createElement('div');
    BODY.appendChild(element);

    expect(document.getElementsByTagName('dIV').length).toBe(1);
  });

  it('work with multi layer node', () => {
    const container = document.createElement('div');
    BODY.appendChild(container);

    const element1 = document.createElement('div');
    const element2 = document.createElement('div');
    container.appendChild(element1);
    container.appendChild(element2);

    expect(document.getElementsByTagName('div').length).toBe(3);
  });

  it('work with append and remove', () => {
    const element = document.createElement('div');
    BODY.appendChild(element);
    expect(document.getElementsByTagName('div').length).toBe(1);

    BODY.removeChild(element);
    expect(document.getElementsByTagName('div').length).toBe(0);
  });

  it('not work with elements inserted into node removed from the tree', () => {
    const outer = document.createElement('div');
    const middle = document.createElement('div');
    const inner = document.createElement('div');

    BODY.appendChild(outer);
    outer.appendChild(middle);
    middle.appendChild(inner);
    outer.removeChild(middle);

    const newElement = document.createElement('div');
    inner.appendChild(newElement);
    expect(document.getElementsByTagName('div').length).toBe(1);
  });

  it('work with body', () => {
    expect(document.getElementsByTagName('body').length).toBe(1);
  });

  it('not work with meta', () => {
    expect(document.getElementsByTagName('meta').length).toBe(0);
  });

  it('not work with head', () => {
    expect(document.getElementsByTagName('head').length).toBe(1);
  });

  it('not work with script', () => {
    expect(document.getElementsByTagName('script').length).toBe(0);
  });

  it('not work with a non existent label', () => {
    expect(document.getElementsByTagName('testtag').length).toBe(0);
  });

});
